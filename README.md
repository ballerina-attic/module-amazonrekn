# Ballerina Amazon Rekognition Connector

This connector allows to use the Amazon Rekognition service through Ballerina. The following section provide you the details on connector operations.

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.990.3                    


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
    secretKey: config:getAsString("SECRET_KEY")
};

amazonrekn:Client blobClient = new(config);
```

##### Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/amazonrekn;
import wso2/amazoncommons;

amazonrekn:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    secretKey: config:getAsString("SECRET_KEY")
};

amazonrekn:Client reknClient = new(config);

public function main() {
    byte[] data = readFile("input.jpeg");
    var result1 = reknClient->detectLabels(untaint data);
    io:println(result1);

    amazoncommons:S3Object s3obj = { bucket: "mybucket", name: "input.jpeg" };
    var result2 = reknClient->detectText(s3obj);
    io:println(result2);
}

function readFile(string path) returns byte[] {
    io:ReadableByteChannel ch = io:openReadableFile(path);
    byte[] output = [];
    int i = 0;
    while (true) {
        (byte[], int) (buff, n) = check ch.read(1000);
        if (n == 0) {
            break;
        }
        foreach byte b in buff {
            output[i] = b;
            i += 1;
        }
    }
    _ = ch.close();
    return output;
}
```
