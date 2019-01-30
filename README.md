# Ballerina Amazon Rekognition Connector

This connector allows to use the Amazon Rekognition service through Ballerina. The following section provide you the details on connector operations.

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.991.0                    


The following sections provide you with information on how to use the Amazon Rekognition Service Connector.

- [Contribute To Develop](#contribute-to-develop)
- [Working with Amazon Rekognition Service Connector actions](#working-with-amazon-rekognition-service-connector)
- [Sample](#sample)

### Contribute To develop

Clone the repository by running the following command 
```shell
git clone https://github.com/wso2-ballerina/module-amazonrekn
```

### Working with Amazon Rekognition Service Connector

First, import the `wso2/amazonrekn` module into the Ballerina project.

```ballerina
import wso2/amazonrekn;
```

In order for you to use the Amazon Rekognition Service Connector, first you need to create an Amazon Rekognition Service Connector client.

```ballerina
amazonrekn:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

amazonrekn:Client blobClient = new(config);
```

##### Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/amazonrekn;

amazonrekn:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

amazonrekn:Client blobClient = new(config);

public function main(string... args) {
    _ = blobClient->createContainer("ctnx1");
    _ = blobClient->putBlob("ctnx1", "blob1", [1, 2, 3, 4, 5]);
    var result = blobClient->getBlob("ctnx1", "blob1");
    io:println(result);
}
```
