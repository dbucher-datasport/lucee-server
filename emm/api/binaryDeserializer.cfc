component extends="taffy.core.nativeJsonDeserializer" {

    // Dummy deserializer to intercept requests with binary body content
    any function getFromBinary( body )
        taffy_mime="multipart/form-data,application/pdf,application/msword,image/gif,image/jpeg,image/png" /* List of acceptable binary mime types */
    {
        return {};//Dummy data to prevent Taffy errors. We will handle the binary directly in the resource.
    }

}