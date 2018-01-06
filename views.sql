    CREATE VIEW getrequests_by_date AS
    SELECT date_trunc('day'::text, log."time") AS day,
        count(log.method) AS requests
    FROM log
    WHERE log.method = 'GET'::text
    GROUP BY (date_trunc('day'::text, log."time"));

    CREATE VIEW errors_by_date AS
    SELECT date_trunc('day'::text, log."time") AS day,
        count(log.status) AS errors
    FROM log
    WHERE log.status <> '200 OK'::text
    GROUP BY (date_trunc('day'::text, log."time"))
    ORDER BY (count(log.status)) DESC;

    CREATE VIEW requests_and_errors AS
     SELECT getrequests_by_date.day,
        errors_by_date.errors,
        getrequests_by_date.requests
     FROM getrequests_by_date,
        errors_by_date
    WHERE getrequests_by_date.day = errors_by_date.day
    GROUP BY getrequests_by_date.day, errors_by_date.errors, getrequests_by_date.requests;

 CREATE VIEW error_percentages AS
    SELECT requests_and_errors.day,
        requests_and_errors.requests,
        requests_and_errors.errors,
        round(requests_and_errors.errors::numeric / requests_and_errors.requests::numeric * 100::numeric, 2) AS percentage

   FROM requests_and_errors
  GROUP BY requests_and_errors.day, requests_and_errors.requests, requests_and_errors.errors
  ORDER BY (round(requests_and_errors.errors::numeric / requests_and_errors.requests::numeric * 100::numeric, 2)) DESC;

CREATE VIEW over_1prc_error AS
    SELECT error_percentages.day,
        error_percentages.requests,
        error_percentages.errors,
        error_percentages.percentage
   FROM error_percentages
  WHERE error_percentages.percentage > 1::numeric;

CREATE VIEW most_popular_authors AS
    SELECT authors.name,
        count(log.path) AS hits
    FROM authors
        JOIN articles ON articles.author = authors.id
        JOIN log ON log.path ~~ ('%'::text || articles.slug)
  GROUP BY authors.name
  ORDER BY (count(log.path)) DESC;

CREATE VIEW top_3_articles AS
    SELECT articles.title,
        authors.name,
        count(log.path) AS hits
   FROM articles
     JOIN authors ON articles.author = authors.id
     JOIN log ON log.path ~~ ('%'::text || articles.slug)
  GROUP BY articles.title, authors.name
  ORDER BY (count(log.path)) DESC
  LIMIT 3;