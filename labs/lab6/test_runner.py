import psycopg2
import sys
import time
import unittest

from restaurant_test import RestaurantDataTestCase

conn_string = "host='restaurant_postgres' dbname='restaurant' user='restaurant' password='restaurant'"
# conn_string = "host='localhost' dbname='restaurant' user='restaurant' password='restaurant'"


def err(message):
    print(message, file=sys.stderr)


def log_error(message):
    with open('connection_errors.txt', 'a') as log_file:
        log_file.write(message)
        log_file.write('\n')


def get_cursor():
    count = 0
    conn = None
    while not conn and count < 13:
        count = count + 1
        try:
            conn = psycopg2.connect(conn_string)
        except psycopg2.OperationalError as op_error:
            log_error("Connection not obtained: %sMaking attempt %d in 10 seconds" % (op_error, count + 1))
            time.sleep(10)

    cursor = conn.cursor()
    return cursor


if __name__ == "__main__":
    """Check the database status"""
    cursor = get_cursor()

    cases = unittest.TestLoader().getTestCaseNames(RestaurantDataTestCase)

    for test_name in cases:
        with open("%s.txt" % test_name, 'w') as out:
            runner = unittest.TextTestRunner(verbosity=2, stream=out, descriptions=True)
            result = runner.run(RestaurantDataTestCase(test_name))
            if (not result.failures) and (not result.errors):
                out.truncate(0)
