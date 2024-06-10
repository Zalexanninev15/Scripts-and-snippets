using System.Collections.Specialized;
using System.Text;
using VitNX.Functions.Common.Web;

namespace FileUploader
{
    class Demo
    {
        public static void Upload()
        {
            var log = new StringBuilder();
            SendDataToSites.FileUploader.UploadFile(
                url: "http://example.com/upload",
                filePath: @"C:/some_file.txt",
                values: new NameValueCollection
                {
                    ["key1"] = "value1",
                    ["key2"] = "value2"
                }, 
                progress: (s,e) => log.AppendLine($"Progress: {s} - {e}"),
                completed: (s) => log.AppendLine($"Completed: {s}")
                );
        }
    }
}
