import pandas as pd
import altair as alt

# Load the dataset
df = pd.read_csv('grosmodele/sommes_A.csv', sep='\t')  # Replace with your file path

print(df.head())

# Convert 'Jour' column from format 'j1', 'j2', etc., to integers
df['Jour'] = df['Jour'].str.lstrip('j').astype(int)

print(df.head())

# Group by 'Jour', 'Foret', and 'Essence' and sum up 'SommeBois' values
aggregated_df = df.groupby(['Jour', 'Foret', 'Essence'], as_index=False)['SommeBois'].sum()

# Filter out Forets with no SommeBois > 0
forets_with_positive_SommeBois = aggregated_df[aggregated_df['SommeBois'] > 0]['Foret'].unique()

# Create a selection for filtering by 'Foret'
selection = alt.selection_single(fields=['Foret'], bind=alt.binding_select(options=forets_with_positive_SommeBois))

# Create a line chart
chart = alt.Chart(aggregated_df).mark_line().encode(
    x='Jour:Q',
    y='SommeBois:Q',
    color='Essence:N',
    tooltip=['Jour', 'Foret', 'Essence', 'SommeBois']
).add_selection(
    selection
).transform_filter(
    selection
).properties(
    title="Plans de coupe selon la forêt visée et en fonction de l'essence"
)

# Save the chart as an HTML file
chart.save('exportToHTML/viz_plan_de_coupe-altair.html')
