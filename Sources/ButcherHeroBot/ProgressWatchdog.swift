import Foundation

/// Escalate repeated unproductive navigation to the visual supervisor.
final class ProgressWatchdog {
    private var chart:Int?
    private var points:[(Double,Double)]=[]
    private var pending=false
    private var landmarkPoints:[(Double,Double)]=[]
    func recordMovement() {pending=true}
    func observe(chart:Int?,x:Double,y:Double,eligible:Bool,landmark:(Double,Double)?=nil)->String? {
        defer {pending=false}
        if eligible,let landmark {
            if landmarkPoints.isEmpty || pending {landmarkPoints.append(landmark)}
            if landmarkPoints.count>13 {landmarkPoints.removeFirst()}
            if landmarkPoints.count==13,let first=landmarkPoints.first,
               hypot(landmark.0-first.0,landmark.1-first.1)<4 {
                return "12 navigációs mozdulat után 4 minimappixel alatti nettó haladás; térképrészváltástól független képi újratervezés szükséges"
            }
        } else {landmarkPoints=[]}
        guard eligible,let chart else {points=[];self.chart=nil;return nil}
        if self.chart != chart {self.chart=chart;points=[(x,y)];return nil}
        guard pending else {if points.isEmpty {points=[(x,y)]};return nil}
        points.append((x,y))
        if points.count>13 {points.removeFirst()}
        guard points.count==13,let first=points.first else{return nil}
        let net=hypot(x-first.0,y-first.1)
        if net<80 {
            return "12 végrehajtott navigációs mozdulat után csak \(Int(net))px nettó haladás; képi felügyelői újratervezés szükséges"
        }
        return nil
    }
}
