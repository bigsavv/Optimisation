import pandas as pd
import plotly.express as px
import matplotlib.pyplot as plt

# Load the dataset
df = pd.read_csv('resultats_A.csv')  # Replace with your file path

# Remove the 'Scierie' column if it exists
if 'Scierie' in df.columns:
    df = df.drop(columns=['Scierie'])

# Convert 'Jour' column from format 'j1', 'j2', etc., to integers
# Assumes 'Jour' column exists and follows the format 'j<number>'
df['Jour'] = df['Jour'].str.lstrip('j').astype(int)

# Group by 'Jour', 'Foret', and 'Essence' and sum up 'A' values
aggregated_df = df.groupby(['Jour', 'Foret', 'Essence'], as_index=False)['A'].sum()

# Check the first few rows of the aggregated data
print(aggregated_df.head())

# Filter out Forets with no A > 0
forets_with_positive_A = df[df['A'] > 0]['Foret'].unique()

# Create a function to update the figure based on the selected 'Foret'
def plot_foret(foret):
    filtered_df = df[df['Foret'] == foret] if foret else df
    fig = px.line(filtered_df, x='Jour', y='A', color='Essence',
                  labels={'Jour': 'Day', 'A': 'Value of A'},
                  title='Distribution and Trends of A over Time by Essence')
    return fig

# Initialize the plot with all data
fig = plot_foret(None)

# Add dropdown for filtering by 'Foret'
foret_options = [{'label': foret, 'method': 'restyle', 'args': [{'visible': [foret == f for f in df['Foret']]}]} for foret in forets_with_positive_A]
fig.update_layout(updatemenus=[{
    'buttons': foret_options,
    'direction': 'down',
    'showactive': True,
}])

# Show the figure
fig.show()
fig.write_html("exportToHTML/viz_plan_de_coupe.html")


# Example: Plotting for a specific 'Foret' and 'Essence'
example_foret = 'LacMartin'  # Replace with your desired 'Foret'
example_essence = 'SPF'       # Replace with your desired 'Essence'

# Filter data for plotting
plot_data = aggregated_df[(aggregated_df['Foret'] == example_foret) & (aggregated_df['Essence'] == example_essence)]

# Create the plot
plt.figure(figsize=(10, 6))
plt.plot(plot_data['Jour'], plot_data['A'], marker='o', linestyle='-', color='blue')
plt.title(f'Total Value of A over Time for {example_foret} - {example_essence}')
plt.xlabel('Day')
plt.ylabel('Sum of A')
plt.grid(True)
plt.show()