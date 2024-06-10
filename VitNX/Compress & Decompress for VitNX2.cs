// Compress
byte[] compressed = Data.CompressAndDecompress.CompressBytes(Data.CompressAndDecompress.GetBytes(input));
string output = Encoding.UTF8.GetString(compressed);

// Decompress
string output = Data.CompressAndDecompress.BytesToString(Data.CompressAndDecompress.DecompressBytes(compressed));