"""Arma el sitio: resumen del modelo (site/data.json) y la documentación de dbt (site/docs)."""
import json
import shutil
from pathlib import Path

import duckdb

RAIZ = Path(__file__).resolve().parent.parent
SITE = RAIZ / "site"

TABLAS = {
    "fct_order_items": "Una línea de orden",
    "fct_orders": "Una orden",
    "dim_customers": "Un cliente real",
    "dim_products": "Un producto",
    "dim_sellers": "Un vendedor",
    "dim_date": "Un día",
}


def q(con, sql):
    cur = con.execute(sql)
    cols = [d[0] for d in cur.description]
    return [dict(zip(cols, (float(v) if hasattr(v, "is_finite") else v for v in row))) for row in cur.fetchall()]


def main():
    con = duckdb.connect(str(RAIZ / "olist.duckdb"), read_only=True)
    data = {
        "tablas": [{"nombre": t, "grano": g, "filas": con.execute(f"select count(*) from {t}").fetchone()[0]} for t, g in TABLAS.items()],
        "kpis": q(con, """
            select sum(gross_value) as facturacion, count(*) as ordenes, avg(gross_value) as ticket,
                   avg(is_late::int) as tasa_atraso, avg(review_score) as nota
            from fct_orders where order_status = 'delivered'""")[0],
        "recompra": con.execute("select avg((lifetime_orders > 1)::int) from dim_customers").fetchone()[0],
        "categorias": q(con, """
            select p.category as categoria, sum(f.gross_value) as facturacion
            from fct_order_items f join dim_products p using (product_key)
            where f.order_status = 'delivered'
            group by 1 order by 2 desc limit 8"""),
        "atraso_vs_nota": q(con, """
            select case when is_late then 'Llegó tarde' else 'Llegó a tiempo' end as entrega,
                   avg(review_score) as nota, count(*) as ordenes
            from fct_orders where order_status = 'delivered' and review_score is not null and is_late is not null
            group by 1 order by 1"""),
        "regiones": q(con, """
            select c.region, sum(f.gross_value) as facturacion, count(distinct f.customer_key) as clientes
            from fct_orders f join dim_customers c using (customer_key)
            where f.order_status = 'delivered'
            group by 1 order by 2 desc"""),
    }
    (SITE / "data.json").write_text(json.dumps(data, ensure_ascii=False, indent=1, default=str))
    (SITE / "docs").mkdir(exist_ok=True)
    shutil.copy(RAIZ / "target" / "static_index.html", SITE / "docs" / "index.html")
    print(json.dumps(data["kpis"], default=str))


if __name__ == "__main__":
    main()
