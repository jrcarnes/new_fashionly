view: users {
  sql_table_name: public.users ;;

  ########## Demographics ##########

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: first_name {
    type: string
    hidden: yes
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    hidden: yes
    sql: ${TABLE}.last_name ;;
  }

  dimension: name {
    type: string
    sql: ${first_name} || ' ' || ${last_name} ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [10,20,30,40,50,60,70]
    style: integer
    sql: ${age} ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: gender_short {
    type: string
    sql: LOWER(LEFT(${gender},1)) ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  ########## Address ##########

  dimension: zip {
    group_label: "Address"
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: city {
    group_label: "Address"
    type: string
    sql: ${TABLE}.city ;;
    drill_fields: [zip]
  }

  dimension: state {
    group_label: "Address"
    type: string
    sql: ${TABLE}.state ;;
    drill_fields: [city, zip]
    map_layer_name: us_states
  }

  dimension: country {
    group_label: "Address"
    type: string
    map_layer_name: countries
    drill_fields: [state, city]
    sql: CASE WHEN ${TABLE}.country = 'UK'
        THEN 'United Kingdom'
        ELSE ${TABLE}.country
      END
        ;;
  }

  ########## geography ##########

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

  dimension: approx_latitude {
    type: number
    hidden: yes
    sql: round(${TABLE}.latitude,1) ;;
  }

  dimension: approx_longitude {
    type: number
    hidden: yes
    sql: round(${TABLE}.longitude,1) ;;
  }

  dimension: location {
    group_label: "Geography"
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: approx_location {
    group_label: "Geography"
    type: location
    sql_latitude: ${approx_latitude} ;;
    sql_longitude: ${approx_longitude} ;;
  }

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

  dimension: days_since_signup {
    type: number
    sql: datediff(days, ${created_raw}, getdate()) ;;
  }

  dimension: months_since_signup {
    type: number
    sql: datediff(months, ${created_raw}, getdate()) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: average_age {
    type: average
    sql: ${age} ;;
    drill_fields: [detail*]
  }

  measure: average_days_since_signup {
    type: average
    sql: ${days_since_signup} ;;
    value_format_name: decimal_1
  }

  measure: average_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
    value_format_name: decimal_1
  }

  set: detail {
    fields: [id, name, email, age, created_date, traffic_source]
  }
}
