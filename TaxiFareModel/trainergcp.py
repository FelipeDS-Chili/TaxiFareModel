def get_data():
    """method used in order to get the training data (or a portion of it) from google cloud bucket"""
    pass

def compute_distance(df):
    """method used in order to compute distance of df"""
    pass

def preprocess(df):
    """method that pre-processes the data"""
    df["distance"] = compute_distance(df)
    X_train = df[["distance"]]
    y_train = df["fare_amount"]
    return X_train, y_train

def train_model(X_train, y_train):
    """method that trains the model"""
    rgs = linear_model.Lasso(alpha=0.1)
    rgs.fit(X_train, y_train)
    return rgs


def save_model(reg):
    """method that saves the model into a .joblib file and uploads it on Google Storage /models folder
    HINTS : use joblib library and google-cloud-storage"""

    # saving the trained model to disk is mandatory to then beeing able to upload it to storage
    # Implement here
    print("saved model.joblib locally")

    # Implement here
    print("uploaded model.joblib to gcp cloud storage under \n => {}".format(storage_location))

if __name__ == '__main__':
    df = get_data()
    X_train, y_train = preprocess(df)
    clf = train_model(X_train, y_train)
    save_model(clf)
