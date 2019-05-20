include: "04_products.view.lkml"

view: brand_comparitor {
  extends: [products]

  filter: brand_select {
    suggest_explore: order_items
    suggest_dimension: brand
  }

  dimension: brand_comparitor {
    type: string
    sql: CASE WHEN {% condition brand_select %} ${brand} {% endcondition %}
      THEN ${brand}
      ELSE 'Rest of Population'
      END
      ;;
  }
}
