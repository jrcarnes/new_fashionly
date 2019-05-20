view: inventory_items {
  sql_table_name: public.inventory_items ;;

  ########## ID and Count ##########

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_sold {
    type: count
    drill_fields: [detail*]
    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: number_on_hand {
    type: count
    drill_fields: [detail*]
    filters: {
      field: is_sold
      value: "No"
    }
  }

  ########## logistics ##########

  dimension: is_sold {
    type: yesno
    sql: ${sold_raw} IS NOT NULL ;;
  }

  dimension: days_in_inventory {
    description: "days between created and sold date"
    type: number
    sql: datediff('days', ${created_raw}, coalesce(${sold_raw}, current_date)) ;;
  }

  dimension: days_in_inventory_tier {
    type: tier
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
    style: integer
    sql: ${days_in_inventory} ;;
  }

#   dimension: days_since_arrival {
#     description: "days since created - useful when filtering on sold yesno for items still in inventory"
#     type: number
#     sql: datediff('days', ${created_date}, current_date) ;;
#   }
#
#   dimension: days_since_arrival_tier {
#     type: tier
#     tiers: [0, 5, 10, 20, 40, 80, 160, 360]
#     style: integer
#     sql: ${days_since_arrival} ;;
#   }

########## Product Dimensions ##########

  dimension: product_brand {
    type: string
    hidden: yes
    sql: ${TABLE}.product_brand ;;
  }

  dimension: product_category {
    type: string
    hidden: yes
    sql: ${TABLE}.product_category ;;
  }

  dimension: product_department {
    type: string
    hidden: yes
    sql: ${TABLE}.product_department ;;
  }

  dimension: product_distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: product_name {
    type: string
    hidden: yes
    sql: ${TABLE}.product_name ;;
  }

  dimension: product_retail_price {
    type: number
    hidden: yes
    sql: ${TABLE}.product_retail_price ;;
  }

  dimension: product_sku {
    type: string
    hidden: yes
    sql: ${TABLE}.product_sku ;;
  }

  ########## Time Dimensions ##########

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.sold_at ;;
  }

  ########## financials ##########

  dimension: cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.cost ;;
  }

  measure: total_cost {
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: average_cost {
    type: number
    value_format_name: usd
    sql: ${cost} ;;
  }

  ########## sets ##########

  set: detail {
    fields: [id, created_time, sold_time]
  }

}
