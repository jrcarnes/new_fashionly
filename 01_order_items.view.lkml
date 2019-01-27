view: order_items {
  sql_table_name: public.order_items ;;

  ########## IDs, Foreign Keys, Counts ##########

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    view_label: "Orders"
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: order_count {
    view_label: "Orders"
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [detail*]
  }

  measure: count_distinct_last_28_days {
    label: "Count Sold in Trailing 28 Days"
    type: count
    filters: {
      field: created_date
      value: "28 days"
    }
  }

  ########## TIME DIMENSIONS ##########

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      hour_of_day,
      date,
      day_of_week,
      week,
      week_of_year,
      month,
      month_num,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
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
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}.shipped_at ;;
  }

#   dimension: reporting_group {
#     group_label: "Order Date"
#     sql: CASE
#         WHEN date_part('year', ${created_raw}) = date_part('year', current_date)
#         AND ${created_raw} < current_date THEN 'This Year to Date'
#         CASE WHEN date_part('year', ${created_raw}) + 1 = date_part('year', current_date)
#         AND date_part('dayofyear', ${created_raw}) <= date_part('dayofyear', current_date)
#         THEN 'Last Year to Date'
#         END;;
#   }

  dimension: days_since_sold {
    type: number
    sql: datediff('days', ${created_raw}, current_date) ;;
  }

  dimension: months_since_signup {
    view_label: "Orders"
    type: number
    sql: datediff('months', ${users.created_raw}, ${created_raw}) ;;
  }

  ########## Logistics ##########

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: days_to_process {
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN datediff('days', ${created_raw}, current_date)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN datediff('day', ${created_raw}, ${shipped_raw})*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
        ;;
  }

  dimension: shipping_time {
    type: number
    sql: datediff('days', ${shipped_raw}, ${delivered_raw})*1.0 ;;
  }

  measure: average_days_to_process {
    type: average
    sql: ${days_to_process} ;;
    value_format_name: decimal_2
  }

  measure: average_shipping_time {
    type: average
    sql: ${shipping_time} ;;
    value_format_name: decimal_2
  }

  ########## Finanacials ##########

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }

  dimension: gross_margin {
    type: number
    sql: ${sale_price} - ${inventory_items.cost} ;;
    value_format_name: usd
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    type: tier
    tiers: [0,10,20,30,40,50,60,70,80,90]
    style: interval
    sql: 100 * ${item_gross_margin_percentage} ;;
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    type: sum
    sql: ${gross_margin} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: median_sales_price {
    type: median
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: average_gross_margin {
    type: average
    sql: ${gross_margin} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/NULLIF(${total_sale_price},0) ;;
  }

  measure: average_spend_per_customer {
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price}/NULLIF(${users.count},0) ;;
    drill_fields: [detail*]
  }

  ########## Returns ##########

  dimension: is_returned {
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }

  measure: returned_count {
    type: count
    filters: {
      field: is_returned
      value: "Yes"
    }
    drill_fields: [detail*]
  }

  measure: returned_total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    filters: {
      field: is_returned
      value: "Yes"
    }
  }

  measure: return_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count}/NULLIF(${count},0) ;;
  }

  ########## repeat purchases ##########
  dimension: days_until_next_order {
    view_label: "Repeat Purchase Facts"
    type: number
    sql: datediff('days', ${created_raw}, ${repeat_purchase_facts.next_order_raw}) ;;
  }

  dimension: is_next_order_within_30d {
    view_label: "Repeat Purchase Facts"
    type: yesno
    sql: ${days_until_next_order} <= 30 ;;
  }

  measure: count_with_repeat_purchase_within_30d  {
    view_label: "Repeat Purchase Facts"
    type: count
    filters: {
      field: is_next_order_within_30d
      value: "Yes"
    }
  }

  measure: 30d_repeat_purchase_rate {
    view_label: "Repeat Purchase Facts"
    description: "The percentage of customers who purchase again within 30 days"
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_with_repeat_purchase_within_30d}/NULLIF(${count},0) ;;
    drill_fields: [products.brand, order_count, count_with_repeat_purchase_within_30d, 30d_repeat_purchase_rate]
  }

  measure: first_purchase_count {
    view_label: "Orders"
    type: count_distinct
    sql: ${order_id} ;;
    filters: {
      field: order_facts.is_first_purchase
      value: "Yes"
    }
  }

  ########## Sets ##########

  set: detail {
    fields: [id, order_id, status, created_date, sale_price, products.brand, products.item_name, users.name, users.email]
#     fields: [
#       id,
#       inventory_items.id,
#       inventory_items.product_name,
#       users.id,
#       users.last_name,
#       users.first_name
#     ]
  }
}
