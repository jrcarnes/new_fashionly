view: monthly_user_signup_cohort_size {
  derived_table: {
    sql: SELECT
        TO_CHAR(DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', users.created_at )), 'YYYY-MM') AS created_month,
        COUNT(users.id ) AS cohort_size
      FROM public.users  AS users
      GROUP BY DATE_TRUNC('month', CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', users.created_at ))
      ORDER BY 1 DESC
       ;;
  }

#   WHERE {% condition users.created_month %} users.created_at {% endcondition %}

  dimension: created_month {
    primary_key: yes
    type: date_month
    sql: ${TABLE}.created_month ;;
  }

  dimension: cohort_size {
    type: number
    sql: ${TABLE}.cohort_size ;;
  }

  set: detail {
    fields: [created_month, cohort_size]
  }
}
