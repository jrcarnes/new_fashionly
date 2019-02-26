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
    timeframes: [raw, date, time, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    type: time
    timeframes: [raw, date, time, week, month, year]
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

  dimension: days_since_last_order {
    type: number
    sql: datediff(days, ${latest_order_raw}, getdate()) ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${days_since_last_order} <= 90  ;;
  }

  measure: min_first_order_date {
    type: date
    sql: MIN(${first_order_raw}) ;;
    convert_tz: no
  }

  measure: average_days_since_latest_order {
    type: average
    sql: ${days_since_last_order} ;;
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
    tiers: [0,1,2,3,6,10]
    style: integer
    sql: ${lifetime_orders} ;;
  }

  measure: total_lifetime_orders {
    type: sum
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
    tiers: [0,5,20,50,100,500,1000]
    style: relational
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
  }

  measure: total_lifetime_revenue {
    type: sum
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }

  measure: average_lifetime_revenue {
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }
}
