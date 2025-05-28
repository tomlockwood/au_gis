# TODO: Adapt this script to use the new G-NAF file structure
import os


def get_raw_gnaf_files(prefix):
    sql_list = []
    prefix = prefix.lower()
    # get a dictionary of all files matching the filename prefix
    for root, dirs, files in os.walk(".tmp/"):
        for file_name in files:
            if file_name.lower().startswith(prefix + "_"):
                if file_name.lower().endswith(".psv"):
                    file_path = os.path.join(root, file_name)
                    table = (
                        file_name.lower()
                        .replace(prefix + "_", "", 1)
                        .replace("_psv", "")
                        .replace(".psv", "")
                    )

                    sql = f"\\copy {table} FROM '{file_path}' DELIMITER '|' CSV HEADER;"

                    sql_list.append(sql)

    return sql_list


with open(".tmp/copy.sql", "w+") as f:
    for line in get_raw_gnaf_files("Authority_code"):
        f.write(f"{line}\n")
    for line in get_raw_gnaf_files("QLD"):
        f.write(f"{line}\n")