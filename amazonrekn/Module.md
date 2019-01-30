Connects to Azure Blob service through Ballerina.

# Module Overview

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.990.0                    

## Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/azureblob;

azureblob:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

azureblob:Client blobClient = new(config);

public function main(string... args) {
    _ = blobClient->createContainer("ctnx1");
    _ = blobClient->putBlob("ctnx1", "blob1", [1, 2, 3, 4, 5]);
    var result = blobClient->getBlob("ctnx1", "blob1");
    io:println(result);
}
```
