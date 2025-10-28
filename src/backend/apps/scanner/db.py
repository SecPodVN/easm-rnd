"""MongoDB connection and database utilities for scanner app."""
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


class MongoDBConnection:
    """Singleton MongoDB connection manager."""

    _instance = None
    _client = None
    _db = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MongoDBConnection, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        # Don't connect immediately - use lazy connection
        pass

    def connect(self):
        """Establish MongoDB connection with error handling."""
        if self._client is not None:
            return  # Already connected

        try:
            mongo_settings = settings.MONGODB_SETTINGS
            host = mongo_settings['host']
            port = mongo_settings['port']
            database = mongo_settings['database']

            connection_string = f"mongodb://{host}:{port}/"

            # Create client with timeout settings
            self._client = MongoClient(
                connection_string,
                serverSelectionTimeoutMS=5000,  # 5 second timeout
                connectTimeoutMS=5000
            )

            # Test the connection
            self._client.admin.command('ping')
            self._db = self._client[database]
            logger.info(f"Connected to MongoDB at {host}:{port}/{database}")

        except (ConnectionFailure, ServerSelectionTimeoutError) as e:
            logger.warning(f"MongoDB connection failed: {e}. Scanner features will be unavailable.")
            self._client = None
            self._db = None
        except Exception as e:
            logger.error(f"Unexpected error connecting to MongoDB: {e}")
            self._client = None
            self._db = None

    @property
    def db(self):
        """Get the MongoDB database instance."""
        if self._db is None:
            self.connect()
        return self._db

    @property
    def client(self):
        """Get the MongoDB client instance."""
        if self._client is None:
            self.connect()
        return self._client

    def close(self):
        """Close MongoDB connection."""
        if self._client:
            try:
                self._client.close()
            except Exception as e:
                logger.error(f"Error closing MongoDB connection: {e}")
            finally:
                self._client = None
                self._db = None


def get_mongodb():
    """Get MongoDB database instance with lazy connection."""
    conn = MongoDBConnection()
    if conn.db is None:
        logger.warning("MongoDB is not available. Scanner operations will fail.")
    return conn.db
