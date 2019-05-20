connection: "thelook_events_redshift"
label: "La Mirada Caliente!"

include: "*.view.lkml"                       # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

datagroup: ecommerce_etl {
  sql_trigger: SELECT max(created_at) FROM public.order_items ;;
  max_cache_age: "24 hours"
}

explore: order_items {
  label: "1) Orders, Items, and Users"
  join: users {
    view_label: "Purchasing Users"
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    view_label: "Purchasing Users"
    type: left_outer
    sql_on: ${order_items.user_id} = ${user_order_facts.user_id} ;;
    relationship: many_to_one
  }

#   join: monthly_user_signup_cohort_size {
#     type: left_outer
#     sql_on: ${users.created_month} = ${monthly_user_signup_cohort_size.created_month} ;;
#     relationship: many_to_one
#   }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: one_to_one
  }

  join: products {
    from: brand_comparitor
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${inventory_items.product_distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  join: order_facts {
    view_label: "Orders"
    type: left_outer
    sql_on: ${order_items.order_id} = ${order_facts.order_id} ;;
    relationship: many_to_one
  }

  join: repeat_purchase_facts {
    type: left_outer
    sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id} ;;
    relationship: many_to_one
  }
}

explore: events {
  label: "2) Web Event Data"

  join: sessions {
    type: left_outer
    sql_on: ${events.session_id} = ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: session_landing_page {
    from: events
    type: left_outer
    sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id} ;;
    fields: [session_landing_page.simple_page_info*]
    relationship: one_to_one
  }

  join: session_bounce_page {
    from: events
    type: left_outer
    sql_on: ${sessions.landing_event_id} = ${session_bounce_page.event_id} ;;
    fields: [session_bounce_page.simple_page_info*]
    relationship: one_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${sessions.session_user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    type: left_outer
    sql_on: ${users.id} = ${user_order_facts.user_id} ;;
    relationship: one_to_one
    view_label: "Users"
  }

  join: product_viewed {
    from: products
    type: left_outer
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }
}
