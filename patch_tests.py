import re
with open('Tests/MapTilerSDKTests/MTStyleTests.swift', 'r') as f:
    content = f.read()

content = content.replace('#expect(js.contains("\\(MTBridge.mapObject).style.addImage(\\"---!@#\\",")))', '#expect(js.contains("\\(MTBridge.mapObject).style.addImage(\\"---!@#\\","))')

with open('Tests/MapTilerSDKTests/MTStyleTests.swift', 'w') as f:
    f.write(content)
