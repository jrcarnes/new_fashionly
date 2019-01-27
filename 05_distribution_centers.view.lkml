view: distribution_centers {
  sql_table_name: public.distribution_centers ;;

  ########## ids and count ##########

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, products.count]
  }

  ########## Geo ##########

  dimension: latitude {
    type: number
    hidden: yes
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    hidden: yes
    sql: ${TABLE}.longitude ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  ########## DC attributes ##########

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
}
