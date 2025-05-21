from faker_datasets import Provider, add_dataset, with_datasets, BaseProvider
import pandas as pd
import random

class SeriesProvider(BaseProvider):
    def __init__(self, generator):
        super().__init__(generator)
        self.titoli=pd.read_csv('tvs.csv')['name'].dropna().tolist()
    def serie(self):
        return random.choice(self.titoli)

