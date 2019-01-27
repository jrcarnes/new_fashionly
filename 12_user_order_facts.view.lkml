view: user_order_facts {
  derived_table: {
    sql: SELECT
        user_id,
        COUNT(DISTINCT order_id ) AS lifetime_orders,
        SUM(sale_price ) AS lifetime_revenue,
        MIN(created_at) AS first_order,
        MAX(created_at) AS latest_order,
        COUNT(DISTINCT DATE_TRUNC('month', created_at)) AS number_of_distinct_months_with_orders
      FROM public.order_items  AS order_items
      WHERE user_id = 1
      GROUP BY 1
       ;;
    datagroup_trigger: ecommerce_etl
    distribution: "user_id"
    sortkeys: ["user_id"]
  }

  dimension: user_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  ########## time and cohort fields ##########

  dimension_group: first_order {
    type: time
    timeframes: [date, time, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    type: time
    timeframes: [date, time, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }

  dimension: days_as_customer {
    description: "Days between first and latest order"
    type: number
    sql: DATEDIFF('days', ${TABLE}.first_order, ${TABLE}.latest_order)+1 ;;
  }

  dimension: days_as_customer_tiered {
    type: tier
    tiers: [0,1,7,14,21,28,30,60,90,120]
    sql: ${days_as_customer} ;;
    style: integer
  }

  ########## lifetime behavior ##########

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension: lifetime_orders_tier {
    type: tier
    tiers: [0,1,2,3,5,10]
    style: integer
    sql: ${lifetime_orders} ;;
  }

  measure: average_lifetime_orders {
    type: average
    value_format_name: decimal_2
    sql: ${lifetime_orders} ;;
  }

  dimension: number_of_distinct_months_with_orders {
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
  }

  dimension: lifetime_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_revenue_tier {
    type: tier
    tiers: [0,25,50,100,200,500,1000]
    style: relational
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
  }

  measure: average_lifetime_revenue {
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }
}
