view: repeat_purchase_facts {
  derived_table: {
    sql: SELECT
        order_items.order_id,
        COUNT(DISTINCT repeat_order_items.id) as number_subsequent_orders,
        MIN(repeat_order_items.created_at) as next_order_date,
        MIN(repeat_order_items.id) as next_order_id
      FROM public.order_items
      LEFT JOIN public.order_items as repeat_order_items ON order_items.user_id = repeat_order_items.user_id
        AND order_items.created_at < repeat_order_items.created_at
      GROUP BY 1
       ;;

    datagroup_trigger: ecommerce_etl
    distribution: "order_id"
    sortkeys: ["order_id"]
  }

  dimension: order_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: next_order_id {
    type: number
    sql: ${TABLE}.next_order_id ;;
    hidden: yes
  }

  dimension: has_subsequent_order {
    type: yesno
    sql: ${next_order_id} > 0 ;;
  }

  dimension: number_subsequent_orders {
    type: number
    sql: ${TABLE}.number_subsequent_orders ;;
  }

  dimension_group: next_order {
    type: time
    timeframes: [raw, date]
    sql: ${TABLE}.next_order_date ;;
    hidden: yes
  }
}
