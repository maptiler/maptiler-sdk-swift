--- Sources/MapTilerSDK/Map/Extensions/MTNavigable/MTNavigable.swift
+++ Sources/MapTilerSDK/Map/Extensions/MTNavigable/MTNavigable.swift
@@ -82,6 +82,11 @@
     ///    - animationOptions: Animation options.
     func snapToNorth(animationOptions: MTAnimationOptions?) async
 
+    /// Resets the map bearing to 0 degrees.
+    /// - Parameters:
+    ///    - animationOptions: Animation options.
+    func resetNorth(animationOptions: MTAnimationOptions?) async
+
     /// Sets the padding in pixels around the viewport.
     /// - Parameters:
     ///    - options: Padding options.
