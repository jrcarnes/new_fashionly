view: products {
  sql_table_name: public.products ;;

  ########## id and counts ##########

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    type: count_distinct
    drill_fields: [brand, department_count, category_count, count]
    sql: ${brand} ;;
  }

  measure: category_count {
    type: count_distinct
    drill_fields: [category, brand_count, department_count, count]
    sql: ${category} ;;
  }

  measure: department_count {
    type: count_distinct
    drill_fields: [department, brand_count, category_count, count]
    sql: ${department} ;;
  }

  ########## product hierarchy ##########

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    drill_fields: [category, name]
    link: {
      label: "Website"
      url: "http://www.google.com/search?q={{ value | encode_uri }}+clothes&btnI"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | encode_uri }}.com"
    }
    link: {
      label: "{{value}} Analytics Dashboard"
#       url: "/dashboards/8?Brand%20Name={{ value | encode_uri }}"
      url: "/dashboards/140?Brand={{ value | encode_uri }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  ########## financials ##########
  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  ########## set ##########
  set: detail {
    fields: [id, name, brand, category, department, retail_price]
  }
}
