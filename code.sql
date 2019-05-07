/* Each task is separated by a header.  Project tasks #3 through
   #7 are cumulative, and it is redundant to show them all
   separately. Therefore, they show up inside task #8.
   Also, the code for the bonus section (#9) was modified to show
   the aggregate churn for the presentation.  This code is included
   in the presentation notes for that slide (lost after the
   conversion for PDF format), and included here below as
   the bonus code.

   Some of the column names don't exactly match the instructions
   for this course, but this is a personal choice.  Also, month
   dates are set as -00 for the start of a month and -99 as the end.
   This, I feel, gives a clearer output when we are looking at a
   month, and when we are looking at data that represents just one
   day.  It also allows for > (greater than) instead of >= in the 
   day vs. month selection for data inclusion.  Again, I do this 
   as a matter of my style and for readability.
*/

/*-------------------------------------|
  Task 1 - Getting a feel for the data
--------------------------------------*/

SELECT *
  FROM subscriptions
  LIMIT 100;  -- For data feel

SELECT *
  FROM subscriptions
  GROUP BY segment;  -- Better shows segments

/*-------------------------------------|
  Task 2 - Looking at the start and 
           end dates
--------------------------------------*/

SELECT MIN(subscription_end),
       MAX(subscription_end)
  FROM subscriptions;

SELECT subscription_end
  FROM subscriptions
  GROUP BY subscription_end
  ORDER BY subscription_end;

/* The subscription end times range from Jan 1st, 2017, to Mar 31st,
   2017.  The second query shows the range of dates.  It is fairly 
   consistent over that time.
*/

/*-------------------------------------|
  Task 8 - Includes tasks 3 through 7.
     I do have code for each task along
     the way, but that is just for
     looking at each step to see if the
     data looks reasonable.
--------------------------------------*/

WITH
 months AS
 (  SELECT '2017-01-00' as m_beg,
           '2017-01-99' as m_end
   UNION
    SELECT '2017-02-00' as m_beg,
           '2017-02-99' as m_end
   UNION
    SELECT '2017-03-00' as m_beg,
           '2017-03-99' as m_end
 ),

 c_join AS
 ( SELECT * FROM subscriptions
   CROSS JOIN Months
 ),

status AS
 (SELECT 
   c_join.id,
   c_join.m_beg AS month,
   CASE
    WHEN (c_join.segment = '87' AND
          c_join.subscription_start < c_join.m_beg AND
          (c_join.subscription_end > c_join.m_beg OR
           c_join.subscription_end Is Null) ) Then 1
    ELSE 0
    END AS is_active_87,
   CASE
    WHEN (c_join.segment = '87' AND
          c_join.subscription_end > c_join.m_beg AND
          c_join.subscription_end < c_join.m_end)
        Then 1
    ELSE 0
   END AS is_canceled_87,
   CASE
    WHEN (c_join.segment = '30' AND
          c_join.subscription_start < c_join.m_beg AND
          (c_join.subscription_end > c_join.m_beg OR
           c_join.subscription_end Is Null) ) Then 1
    ELSE 0
    END AS is_active_30,
   CASE
    WHEN (c_join.segment = '30' AND
          c_join.subscription_end > c_join.m_beg AND
          c_join.subscription_end < c_join.m_end)
        Then 1
    ELSE 0
   END AS is_canceled_30
   FROM c_join
 ),

status_aggregate AS
 (SELECT month,
      Sum(is_active_87) AS sum_active_87,
      Sum(is_active_30) AS sum_active_30,
      Sum(is_canceled_87) AS sum_canceled_87,
      Sum(is_canceled_30) AS sum_canceled_30
    FROM status
    GROUP BY month
    ORDER BY month
 )

Select month As 'Month',
        Round(sum_canceled_87 * 100. / sum_active_87, 2)
               AS 'Percent Churn Segment 87',
        Round(sum_canceled_30 * 100. / sum_active_30, 2)
               AS 'Percent Churn Segment 30'
    FROM status_aggregate;

/*---------------------------------------------|
  Task 9 (Bonus)  Starting with table 'status'
  the segment is captured AND hard coded results
  are removed.
----------------------------------------------*/

WITH
 months AS
 (  SELECT '2017-01-00' as m_beg,
           '2017-01-99' as m_end
   UNION
    SELECT '2017-02-00' as m_beg,
           '2017-02-99' as m_end
   UNION
    SELECT '2017-03-00' as m_beg,
           '2017-03-99' as m_end
 ),

 c_join AS
 ( SELECT * FROM subscriptions
   CROSS JOIN Months
 ),

status AS
 (SELECT 
   id,
   m_beg AS month,
   segment,
   CASE
    WHEN (subscription_start < m_beg AND
           (subscription_end > m_beg OR
            subscription_end Is Null) ) Then 1
    ELSE 0
    END AS is_active,
   CASE
    WHEN (subscription_end > m_beg AND
          subscription_end < m_end)
        Then 1
    ELSE 0
   END AS is_canceled
   FROM c_join
 ),

status_aggregate AS
 (SELECT
      month,
      segment,
      Sum(is_active)   AS sum_active,
      Sum(is_canceled) AS sum_canceled
    FROM status
    GROUP BY month, segment
    ORDER BY month, segment
 )

SELECT month AS 'Month',
       segment AS 'Segment',
        Round(sum_canceled * 100. / sum_active, 2)
               AS 'Percent Churn'
    FROM status_aggregate;

--------------------------------------------------------
/* From the presentation: The aggregate churn results
   (both segments).
*/
--------------------------------------------------------

WITH
 months AS
 (  SELECT '2017-01-00' AS m_beg,
           '2017-01-99' AS m_end
   UNION
    SELECT '2017-02-00' AS m_beg,
           '2017-02-99' AS m_end
   UNION
    SELECT '2017-03-00' AS m_beg,
           '2017-03-99' AS m_end
 ),

 c_join AS
 ( SELECT * FROM subscriptions
   CROSS JOIN months
 ),

status AS
 (SELECT 
   id,
   m_beg AS month,
   segment,
   CASE
    WHEN (subscription_start < m_beg AND
           (subscription_end > m_beg OR
            subscription_end IS NULL) ) THEN 1
    ELSE 0
    END AS is_active,
   CASE
    WHEN (subscription_end > m_beg AND
          subscription_end < m_end)
        THEN 1
    ELSE 0
   END AS is_canceled
   FROM c_join
 ),

status_aggregate AS
 (SELECT
      month,
      Sum(is_active)   AS sum_active,
      Sum(is_canceled) AS sum_canceled
    FROM status
    GROUP BY 1
    ORDER BY 1
 )

SELECT month AS Month,
        Round(sum_canceled * 100. / sum_active, 2)
               AS 'Percent Churn'
    FROM status_aggregate;