<h2>Quickblox: Uploading from file, downloading to file</h2>

Unfortunately QuickBlox iOS SDK has methods for downloading and uploading only using memory. We need pass the NSData or receive NSData. It’s really problem. In this sample I provide example, how to upload content from file, and how to download to file.

<h3>Uploading</h3>

<h3>Downloading</h3>

<h3>Methods from QuickBlox iOS SDK</h3>
<pre>
#pragma mark -
#pragma mark Upload file using BlobObjectAccess

/**
 Upload file using BlobObjectAccess
 
 @param data File
 @param blobWithWriteAccess An instance of QBCBlobObjectAccess
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)uploadFile:(NSData *)data
      blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess
             successBlock:(void(^)(QBResponse *response))successBlock
              statusBlock:(QBRequestStatusUpdateBlock)statusBlock
               errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Download file

/**
 Download file
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)downloadFileWithUID:(NSString *)UID
                      successBlock:(void(^)(QBResponse *response, NSData *fileData))successBlock
                       statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                        errorBlock:(void(^)(QBResponse *response))errorBlock;

#pragma mark -
#pragma mark Tasks

/**
 Upload File task. Contains 3 requests: Create Blob, upload file, declaring file uploaded
 
 @param data file to be uploaded
 @param fileName name of the file
 @param contentType type of the content in mime format
 @param isPublic blob's visibility
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)TUploadFile:(NSData*)data
                  fileName:(NSString*)fileName
               contentType:(NSString*)contentType
                  isPublic:(BOOL)isPublic
              successBlock:(void(^)(QBResponse *response, QBCBlob* blob))successBlock
               statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                errorBlock:(void(^)(QBResponse *response))errorBlock;

/**
 Download File task. Contains 2 requests: Get Blob with ID, download file

 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */

+ (QBRequest *)TDownloadFileWithBlobID:(NSUInteger)blobID
                          successBlock:(void(^)(QBResponse *response, NSData *fileData))successBlock
                           statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                            errorBlock:(void(^)(QBResponse *response))errorBlock;
</pre>
