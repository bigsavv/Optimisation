import pandas as pd
import plotly.express as px


# Load the dataset
df = pd.read_csv('resultats_A.csv')  # Replace with your file path




# Aggregate data
grouped_df = df.groupby(['Jour', 'Essence']).agg({'A': 'sum'}).reset_index()

# Function to create a line plot based on a specific 'Foret'
def plot_foret(foret):
    filtered_df = grouped_df[grouped_df['Foret'] == foret] if foret else grouped_df
    fig = px.line(filtered_df, x='Jour', y='A', color='Essence',
                  labels={'Jour': 'Day', 'A': 'Value of A'},
                  title='Distribution and Trends of A over Time by Essence')
    return fig

# Initialize the plot with all data
fig = plot_foret(None)

# Add dropdown for filtering by 'Foret'
foret_options = [{'label': foret, 'method': 'restyle', 'args': [{'visible': [foret == f for f in grouped_df['Foret']]}]} for foret in grouped_df['Foret'].unique()]
fig.update_layout(updatemenus=[{
    'buttons': foret_options,
    'direction': 'down',
    'showactive': True,
}])

# Show the figure
fig.show()

