import string
import requests
import pandas as pd
from datetime import datetime
import os
import sys

URL = sys.argv[1]
API_KEY = sys.argv[2]
API_HOST = sys.argv[3]


url = URL

querystring = {"interval":"60m","symbol":"^BSESN","range":"1D","region":"IN"}

headers = {
	"X-RapidAPI-Key": f"{API_KEY}",
	"X-RapidAPI-Host": f"{API_HOST}"
}


try:   
	response = requests.get(url, headers=headers, params=querystring).json()

	if response['chart']['result'] is None:
		raise Exception('code :', response['chart']['error']['code'], response['chart']['error']['description'])

	del response['chart']['result'][0]['meta']

	# Extract and Explode Timestamp data
	df_api_data_extract_ts = pd.json_normalize(response['chart']['result'][0]).explode('timestamp',ignore_index=True).drop(columns='indicators.quote')
	
	# Extract and Explode Quote data
	df_api_data_extract_quote = pd.json_normalize(response['chart']['result'][0]['indicators']['quote'][0]).explode(column=list(response['chart']['result'][0]['indicators']['quote'][0].keys()),ignore_index=True)
	
	# Merge Both DF
	df_api_data_merged = pd.merge(df_api_data_extract_quote,df_api_data_extract_ts, left_index=True, right_index=True)
	
	# Apply UNIX Timestamp to UTC
	df_api_data_merged['timestamp'] = df_api_data_merged['timestamp'].apply(lambda x : datetime.utcfromtimestamp(x))

	# Rearrange Column
	df_api_data_merged = df_api_data_merged[['timestamp', 'open', 'close', 'high', 'low', 'volume']]

	# Assign Data Type 
	schema = {'timestamp' : 'string', 'open' : 'string', 'close' : 'string', 'high' : 'string', 'low' : 'string', 'volume' : 'string'}
	df_api_data_merged = df_api_data_merged.astype(schema)
	
	# Export df to CSV
	storage_folder = 'data'

	file_suffix = datetime.now().strftime("%Y%m%d_%H%M%S")

	if not os.path.exists(os.path.join(os.getcwd(), storage_folder)):
		os.makedirs(os.path.join(os.getcwd(), storage_folder))

	filename = f'sensex_{file_suffix}.csv'

	path = os.path.join(os.getcwd(), storage_folder, filename)
	df_api_data_merged.to_csv(path, index=False, header=True)

except Exception as error:
    print(repr(error))