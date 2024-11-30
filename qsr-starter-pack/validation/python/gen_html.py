import json
import pytd
import pandas as pd
from validation.python.pretty_html_table import build_table
import validation.python.global_var as g


def split_html_content(content, max_size=131072):
    return [
        (i + 1, content[i : i + max_size]) for i in range(0, len(content), max_size)
    ]


def main(database, td_write_table, run_type="create"):
    try:
        client = pytd.Client(
            apikey=g.td_api_key,
            endpoint=g.td_endpoint_base,
            database=database,
            default_engine="presto",
        )
    except BaseException:
        raise Exception("Error calling pytd.Client")

    data_report_missing_tables_in_src = client.query(
        f"select * from report_missing_tables_in_src order by src_table_name, ref_table_name"
    )
    df_data_report_missing_tables_in_src = pd.DataFrame(
        **data_report_missing_tables_in_src
    )

    report_missing_tables_in_src = (
        build_table(df_data_report_missing_tables_in_src, "blue_light")
        if not df_data_report_missing_tables_in_src.empty
        else None
    )
    report_missing_tables_in_src_table = (
        f"""
            <div>
                <h3>Error! Missing Table:</h3>
                {report_missing_tables_in_src}
            </div>
        """
        if report_missing_tables_in_src
        else ""
    )

    data_report_missing_src_columns = client.query(
        f"select * from report_missing_src_columns order by src_table_name, src_column_name, ref_table_name, ref_column_name"
    )
    df_data_report_missing_src_columns = pd.DataFrame(**data_report_missing_src_columns)

    report_missing_src_columns = (
        build_table(df_data_report_missing_src_columns, "blue_light")
        if not df_data_report_missing_src_columns.empty
        else None
    )
    report_missing_src_columns_table = (
        f"""
            <div>
                <h3>Error! Missing Columns:</h3>
                {report_missing_src_columns}
            </div>
        """
        if report_missing_src_columns
        else ""
    )

    data_report_column_type_mismatches = client.query(
        f"select * from report_column_type_mismatches order by src_table_name, src_column_name, ref_table_name, ref_column_name"
    )
    df_data_report_column_type_mismatches = pd.DataFrame(
        **data_report_column_type_mismatches
    )

    report_column_type_mismatches = (
        build_table(df_data_report_column_type_mismatches, "blue_light")
        if not df_data_report_column_type_mismatches.empty
        else None
    )
    report_column_type_mismatches_table = (
        f"""
            <div>
                <h3>Error! Column Type Mismatches:</h3>
                {report_column_type_mismatches}
            </div>
        """
        if report_column_type_mismatches
        else ""
    )

    data_report_extra_tables_in_src = client.query(
        f"select * from report_extra_tables_in_src order by src_table_name, ref_table_name"
    )
    df_data_report_extra_tables_in_src = pd.DataFrame(**data_report_extra_tables_in_src)

    report_extra_tables_in_src = (
        build_table(df_data_report_extra_tables_in_src, "blue_light")
        if not df_data_report_extra_tables_in_src.empty
        else None
    )
    report_extra_tables_in_src_table = (
        f"""
            <div>
                <h3>Warning! Additional tables present:</h3>
                {report_extra_tables_in_src}
            </div>
        """
        if report_extra_tables_in_src
        else ""
    )

    data_report_extra_columns_in_src = client.query(
        f"select * from report_extra_columns_in_src order by src_table_name, src_column_name, ref_table_name, ref_column_name"
    )
    df_data_report_extra_columns_in_src = pd.DataFrame(
        **data_report_extra_columns_in_src
    )

    report_extra_columns_in_src = (
        build_table(df_data_report_extra_columns_in_src, "blue_light")
        if not df_data_report_extra_columns_in_src.empty
        else None
    )
    report_extra_columns_in_src_table = (
        f"""
            <div>
                <h3>Warning! Additional columns present:</h3>
                {report_extra_columns_in_src}
            </div>
        """
        if report_extra_columns_in_src
        else ""
    )

    html_content = f"""
    <html>
        <head>
            <style>
                table, th, td {{
                    border: 1px solid black;
                    border-collapse: collapse;
                }}
                th, td {{
                    padding: 10px;
                    text-align: left;
                }}
            </style>
        </head>
        <body>
            {report_missing_tables_in_src_table}
            {report_missing_src_columns_table}
            {report_column_type_mismatches_table}
            {report_extra_tables_in_src_table}
            {report_extra_columns_in_src_table}
        </body>
    </html>
    """
    # Split the html_content into chunks with row numbers
    html_chunks_with_rownum = split_html_content(html_content)

    # Create the DataFrame with the split content and row numbers
    df_html = pd.DataFrame(html_chunks_with_rownum, columns=["rownum", "html_content"])

    try:
        client.load_table_from_dataframe(
            df_html, td_write_table, writer="bulk_import", if_exists="overwrite"
        )
    except BaseException:
        raise Exception("Error writing table back into TD Database")
