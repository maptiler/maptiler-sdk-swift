--- Sources/MapTilerSDK/Map/Extensions/MTNavigable/MTMapView+MTNavigable.swift
+++ Sources/MapTilerSDK/Map/Extensions/MTNavigable/MTMapView+MTNavigable.swift
@@ -459,6 +459,17 @@
         runCommand(SnapToNorth(animationOptions: animationOptions), completion: completionHandler)
     }
 
+    /// Resets the map bearing to 0 degrees.
+    /// - Parameters:
+    ///   - animationOptions: Animation options.
+    ///   - completionHandler: A handler block to execute when function finishes.
+    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
+    public func resetNorth(
+        animationOptions: MTAnimationOptions? = nil,
+        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
+    ) {
+        runCommand(ResetNorth(animationOptions: animationOptions), completion: completionHandler)
+    }
+
     /// Returns the map's current center.
     ///
     /// The map's current geographical center.
@@ -1001,6 +1012,15 @@
         }
     }
 
+    /// Resets the map bearing to 0 degrees.
+    /// - Parameters:
+    ///   - animationOptions: Animation options.
+    public func resetNorth(animationOptions: MTAnimationOptions? = nil) async {
+        await withCheckedContinuation { continuation in
+            resetNorth(animationOptions: animationOptions) { _ in
+                continuation.resume()
+            }
+        }
+    }
+
     /// Returns the map's current center.
     ///
     /// The map's current geographical center.
