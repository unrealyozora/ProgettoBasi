from faker_datasets import Provider, add_dataset, with_datasets

@add_dataset("series", "tv_shows.csv")
class SeriesProvider(Provider):
    @with_datasets("series")
    def series(self, series):
        return self.random_element(series)