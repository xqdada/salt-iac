# -*- coding: utf-8 -*-

import os
import pymysql as mysql_driver
from hashlib import md5
from pymysql import MySQLError


class MySQLConnectManager(object):
    def __init__(self, host, port, login_user, login_password, db, connect_timeout=30, charset='utf8',
                 autocommit=False):
        self.conn = mysql_driver.connect(
            host=host,
            port=port,
            user=login_user,
            password=login_password,
            database=db,
            connect_timeout=connect_timeout,
            charset=charset,
            autocommit=autocommit,
            cursorclass=mysql_driver.cursors.DictCursor
        )

        self.cur = self.conn.cursor()

    def __enter__(self):
        return self.conn, self.cur

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.cur.close()
        self.conn.close()


def get_md5_from_db(host, port, login_user, login_password, db_name):
    try:
        with MySQLConnectManager(host, port, login_user, login_password, db_name) as (
                conn, cur):
            cur.execute('select file_url,file_md5 from tb_update_info')
            results = cur.fetchall()
            for idx, row in enumerate(results):
                file_name = row.get('file_url', '').split('/')[-1]
                file_md5 = row.get('file_md5', '')

                print(f'{idx} row: {row}')
                with open('/tmp/db_md5.txt', 'w+', encoding='utf-8') as f:
                    f.write(f'{file_name} {file_md5}\n')
    except MySQLError as e:
        print(f"MySQL error: {e}")


def content_md5(filename):
    with open(filename, 'rb') as f:
        m = md5(f.read())
    return m.hexdigest()


def safe_print(s):
    try:
        print(s)
    except UnicodeEncodeError as e:
        s = s.encode('utf-8', errors='replace').decode('utf-8')
        print(s)


def list_filename_and_md5(root_dir, result_file):
    if not os.path.isabs(root_dir):
        print("root_dir must be an absolute path")
        return

    for root, dirs, files in os.walk(root_dir, topdown=False):
        for file in files:
            file_path = os.path.join(root, file)

            md5_val = content_md5(file_path)
            safe_print(f'FileInfo: file_path={file_path} md5_val={md5_val}')

            basename = file_path.split('/')[-1]
            with open(result_file, 'w+', encoding='utf-8') as f:
                f.write(f'{basename} {md5_val}\n')


def compare_md5_file(src_file, dst_file, result_file):
    try:
        db_md5_set = set()
        with open(src_file, 'r', encoding='utf-8') as f1:
            for line in f1:
                line_part = line.strip('\n').split(' ')
                db_md5_name = line_part[0]
                db_md5_val = line_part[1]
                db_md5_set.add((db_md5_name, db_md5_val))

        with open(result_file, 'w+', encoding='utf-8') as f3:
            with open(dst_file, 'r', encoding='utf-8') as f2:
                for file_md5 in f2:
                    file_md5_part = file_md5.strip('\n').split(' ')
                    file_md5_name = file_md5_part[0]
                    file_md5_val = file_md5_part[1]

                    if (file_md5_name, file_md5_val) not in db_md5_set:
                        print(f'db not exist or md5 value different about file: {file_md5_name} {file_md5_val}\n')
                        f3.write(f'{file_md5_name} {file_md5_val}\n')

    except FileNotFoundError as fnf_err:
        print(f"File not found: {fnf_err}")
    except IOError as io_err:
        print(f"IO error occurred: {io_err}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == '__main__':
    # get_md5_from_db('172.16.0.164', 3306, 'test', 'xxxxxx', 'update_soft')
    # list_filename_and_md5('/mnt/hdisk/upload/', '/tmp/file_md5.txt')

    compare_md5_file('db_md5.txt', 'file_md5.txt', 'compare_md5_rules.txt')

