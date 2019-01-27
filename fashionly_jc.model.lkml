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
  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: one_to_one
  }
  join: products {
    view_label: "Purchased Products"
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
  join: distribution_centers {
    type: left_outer
    sql_on: ${inventory_items.product_distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}
