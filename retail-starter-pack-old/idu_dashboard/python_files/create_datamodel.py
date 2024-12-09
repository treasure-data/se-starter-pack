import os
import sys

##-- Declare ENV Variables from YML file
apikey = os.environ['TD_API_KEY'] 
tdserver = os.environ['TD_API_SERVER']
sink_database = os.environ['SINK_DB']
output_table = os.environ['OUTPUT_TABLE']

#pip-install datamodel create library
os.system(f"{sys.executable} -m pip install td-ml-datamodel-create")

#import all functions and variables from library
from td_ml_datamodel_create import *
