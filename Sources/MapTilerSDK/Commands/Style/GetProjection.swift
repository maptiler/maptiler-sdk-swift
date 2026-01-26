//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetProjection.swift
//  MapTilerSDK
//

package struct GetProjection: MTValueCommand {
    package func toJS() -> JSString {
        // Simple extraction: scan the projection spec; if it contains a globe-like value,
        // return 'globe', otherwise 'mercator'. No expression evaluation.
        return "(()=>{\n" +
        "  try {\n" +
        "    const spec = \(MTBridge.mapObject).getProjection();\n" +
        "    const isGlobeToken = (s) => {\n" +
        "      if (!s) return false;\n" +
        "      const v = String(s).toLowerCase();\n" +
        "      return v === 'globe' || v === 'vertical-perspective' ||\n" +
        "        v === 'vertical_perspective' || v === 'perspective';\n" +
        "    };\n" +
        "    const scan = (v) => {\n" +
        "      if (typeof v === 'string') return isGlobeToken(v);\n" +
        "      if (Array.isArray(v)) return v.some(scan);\n" +
        "      if (v && typeof v === 'object') return scan(v.type);\n" +
        "      return false;\n" +
        "    };\n" +
        "    return scan(spec) ? 'globe' : 'mercator';\n" +
        "  } catch (_) {\n" +
        "    return 'mercator';\n" +
        "  }\n" +
        "})()"
    }
}
