import pandas as pd
import altair as alt
import csv

# Load the dataset
df = pd.read_csv('grosmodele/resultats_A.csv')  # Replace with your file path

# Remove the 'Scierie' column if it exists
if 'Scierie' in df.columns:
    df = df.drop(columns=['Scierie'])

# Convert 'Jour' column from format 'j1', 'j2', etc., to integers
df['Jour'] = df['Jour'].str.lstrip('j').astype(int)

# Group by 'Jour', 'Foret', and 'Essence' and sum up 'A' values
aggregated_df = df.groupby(['Jour', 'Foret', 'Essence'], as_index=False)['A'].sum()

# Filter out Forets with no A > 0
forets_with_positive_A = df[df['A'] > 0]['Foret'].unique()

# Create a selection for filtering by 'Foret'
selection = alt.selection_single(fields=['Foret'], bind=alt.binding_select(options=forets_with_positive_A))

# Create a line chart
chart = alt.Chart(aggregated_df).mark_line().encode(
    x='Jour:Q',
    y='A:Q',
    color='Essence:N',
    tooltip=['Jour', 'Foret', 'Essence', 'A']
).add_selection(
    selection
).transform_filter(
    selection
).properties(
    title="Plans de coupe selon la forêt visée et en fonction de l'essence"
)

# Save the chart as an HTML file
chart.save('exportToHTML/viz_plan_de_coupe-altair.html')
