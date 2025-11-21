"""MongoDB models for scanner app using pymongo."""
from bson import ObjectId
from datetime import datetime
from .db import get_mongodb
import logging

logger = logging.getLogger(__name__)


class BaseMongoModel:
    """Base class for MongoDB models."""

    collection_name = None

    @classmethod
    def get_collection(cls):
        """Get MongoDB collection."""
        db = get_mongodb()
        if db is None:
            raise RuntimeError("MongoDB is not available. Please check MongoDB connection.")
        return db[cls.collection_name]

    @classmethod
    def to_dict(cls, document):
        """Convert MongoDB document to dict with string _id."""
        if document is None:
            return None
        doc_dict = dict(document)
        if '_id' in doc_dict:
            doc_dict['_id'] = str(doc_dict['_id'])
        return doc_dict

    @classmethod
    def to_dict_list(cls, documents):
        """Convert list of MongoDB documents to list of dicts."""
        return [cls.to_dict(doc) for doc in documents]


class Resource(BaseMongoModel):
    """MongoDB model for resources."""

    collection_name = 'resources'

    @classmethod
    def create(cls, resource_data):
        """Create a new resource."""
        collection = cls.get_collection()
        resource_data['created_at'] = datetime.utcnow()
        resource_data['updated_at'] = datetime.utcnow()
        result = collection.insert_one(resource_data)
        resource_data['_id'] = result.inserted_id
        return cls.to_dict(resource_data)

    @classmethod
    def bulk_create(cls, resources_list):
        """Bulk insert resources."""
        collection = cls.get_collection()
        for resource in resources_list:
            resource['created_at'] = datetime.utcnow()
            resource['updated_at'] = datetime.utcnow()
        result = collection.insert_many(resources_list)
        return len(result.inserted_ids)

    @classmethod
    def find_all(cls, filter_dict=None, skip=0, limit=10, sort_by='name', sort_order='asc', search_str=None):
        """Find resources with pagination, filtering, and search."""
        collection = cls.get_collection()
        query = filter_dict or {}

        # Add search functionality
        if search_str:
            query['name'] = {'$regex': search_str, '$options': 'i'}

        # Determine sort order
        sort_direction = 1 if sort_order == 'asc' else -1

        # Execute query with pagination
        cursor = collection.find(query).sort(sort_by, sort_direction).skip(skip).limit(limit)
        total_count = collection.count_documents(query)

        return {
            'data': cls.to_dict_list(cursor),
            'total': total_count,
            'page_size': limit,
            'page_number': (skip // limit) + 1
        }

    @classmethod
    def find_by_id(cls, resource_id):
        """Find resource by ID."""
        collection = cls.get_collection()
        document = collection.find_one({'_id': ObjectId(resource_id)})
        return cls.to_dict(document)

    @classmethod
    def update(cls, resource_id, update_data):
        """Update resource by ID."""
        collection = cls.get_collection()
        update_data['updated_at'] = datetime.utcnow()
        result = collection.update_one(
            {'_id': ObjectId(resource_id)},
            {'$set': update_data}
        )
        return result.modified_count > 0

    @classmethod
    def delete(cls, resource_id):
        """Delete resource by ID."""
        collection = cls.get_collection()
        result = collection.delete_one({'_id': ObjectId(resource_id)})
        return result.deleted_count > 0

    @classmethod
    def bulk_delete(cls, filter_dict):
        """Bulk delete resources matching filter."""
        collection = cls.get_collection()
        result = collection.delete_many(filter_dict)
        return result.deleted_count


class Rule(BaseMongoModel):
    """MongoDB model for rules."""

    collection_name = 'rules'

    @classmethod
    def create(cls, rule_data):
        """Create a new rule."""
        collection = cls.get_collection()
        rule_data['created_at'] = datetime.utcnow()
        rule_data['updated_at'] = datetime.utcnow()
        result = collection.insert_one(rule_data)
        rule_data['_id'] = result.inserted_id
        return cls.to_dict(rule_data)

    @classmethod
    def bulk_create(cls, rules_list):
        """Bulk insert rules."""
        collection = cls.get_collection()
        for rule in rules_list:
            rule['created_at'] = datetime.utcnow()
            rule['updated_at'] = datetime.utcnow()
        result = collection.insert_many(rules_list)
        return len(result.inserted_ids)

    @classmethod
    def find_all(cls):
        """Find all rules."""
        collection = cls.get_collection()
        cursor = collection.find({})
        return cls.to_dict_list(cursor)

    @classmethod
    def find_by_id(cls, rule_id):
        """Find rule by ID."""
        collection = cls.get_collection()
        document = collection.find_one({'_id': ObjectId(rule_id)})
        return cls.to_dict(document)

    @classmethod
    def update(cls, rule_id, update_data):
        """Update rule by ID."""
        collection = cls.get_collection()
        update_data['updated_at'] = datetime.utcnow()
        result = collection.update_one(
            {'_id': ObjectId(rule_id)},
            {'$set': update_data}
        )
        return result.modified_count > 0

    @classmethod
    def delete(cls, rule_id):
        """Delete rule by ID."""
        collection = cls.get_collection()
        result = collection.delete_one({'_id': ObjectId(rule_id)})
        return result.deleted_count > 0

    @classmethod
    def bulk_delete(cls, filter_dict):
        """Bulk delete rules matching filter."""
        collection = cls.get_collection()
        result = collection.delete_many(filter_dict)
        return result.deleted_count


class Finding(BaseMongoModel):
    """MongoDB model for findings."""

    collection_name = 'findings'

    @classmethod
    def create(cls, finding_data):
        """Create a new finding."""
        collection = cls.get_collection()
        finding_data['created_at'] = datetime.utcnow()
        result = collection.insert_one(finding_data)
        finding_data['_id'] = result.inserted_id
        return cls.to_dict(finding_data)

    @classmethod
    def find_all(cls):
        """Find all findings."""
        collection = cls.get_collection()
        cursor = collection.find({})
        return cls.to_dict_list(cursor)

    @classmethod
    def clear_all(cls):
        """Clear all findings."""
        collection = cls.get_collection()
        result = collection.delete_many({})
        return result.deleted_count

    @classmethod
    def get_severity_summary(cls):
        """Get count of findings by severity."""
        collection = cls.get_collection()
        pipeline = [
            {
                '$group': {
                    '_id': '$severity',
                    'count': {'$sum': 1}
                }
            }
        ]
        results = list(collection.aggregate(pipeline))

        # Format results
        severity_counts = {
            'CRITICAL': 0,
            'HIGH': 0,
            'MEDIUM': 0,
            'LOW': 0,
            'INFO': 0
        }

        for result in results:
            severity = result['_id']
            if severity and severity in severity_counts:
                severity_counts[severity] = result['count']

        return severity_counts

    @classmethod
    def get_by_resource_type(cls):
        """Get findings grouped by resource type."""
        collection = cls.get_collection()
        pipeline = [
            {
                '$group': {
                    '_id': '$resource_type',
                    'count': {'$sum': 1}
                }
            }
        ]
        results = list(collection.aggregate(pipeline))
        return [{'resource_type': r['_id'], 'count': r['count']} for r in results]

    @classmethod
    def get_by_region(cls):
        """Get findings grouped by region (requires lookup to resources)."""
        collection = cls.get_collection()
        pipeline = [
            {
                '$lookup': {
                    'from': 'resources',
                    'localField': 'resource_id',
                    'foreignField': '_id',
                    'as': 'resource'
                }
            },
            {
                '$unwind': {
                    'path': '$resource',
                    'preserveNullAndEmptyArrays': True
                }
            },
            {
                '$group': {
                    '_id': '$resource.region',
                    'count': {'$sum': 1}
                }
            }
        ]
        results = list(collection.aggregate(pipeline))
        return [{'region': r['_id'] or 'unknown', 'count': r['count']} for r in results]
