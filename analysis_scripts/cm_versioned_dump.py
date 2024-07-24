from io import StringIO
import sys

import pandas as pd

# https://tech.marksblogg.com/git-track-changes-in-media-office-documents.html

sheet_name = "Rules"
# output = StringIO()
df = pd.read_excel(sys.argv[1], sheet_name=sheet_name)
df = df[df[['Min SDK Version', 'Max SDK Version']].notnull().any(axis=1)][df.columns[0:3]]\
  .to_csv(header=False,
          index=False)
# print(output.getvalue())
print(df)
