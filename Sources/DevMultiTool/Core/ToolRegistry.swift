import Foundation

class ToolRegistry: ObservableObject {
    @Published var tools: [any DeveloperTool] = []
    
    init() {
        tools.append(UUIDGeneratorTool())
        tools.append(Base64ConverterTool())
        tools.append(SampleTextTool())
        tools.append(JSONToCSVTool())
        tools.append(JSONFillerTool())
        tools.append(JWTDecoderTool())
        tools.append(UnixTimestampTool())
        tools.append(URLEncoderTool())
        tools.append(ColorConverterTool())
        tools.append(JSONFormatterTool())
        tools.append(HashGeneratorTool())
        tools.append(StringInspectorTool())
        tools.append(NetworkInfoTool())
        tools.append(URLParserTool())
    }
}
