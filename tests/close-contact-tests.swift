import Foundation
@main struct Tests {
 static func main() {
  precondition(CloseContactPolicy.observationLimit(treeConfidence:0.45,hp:67,nearbyThreats:0,health:1)==2)
  precondition(CloseContactPolicy.observationLimit(treeConfidence:0.1,hp:67,nearbyThreats:0,health:1)==7)
  precondition(CloseContactPolicy.observationLimit(treeConfidence:0.45,hp:nil,nearbyThreats:0,health:1)==7)
  precondition(CloseContactPolicy.observationLimit(treeConfidence:0.45,hp:11400,nearbyThreats:0,health:1)==7)
  precondition(CloseContactPolicy.observationLimit(treeConfidence:0.45,hp:67,nearbyThreats:1,health:1)==7)
  precondition(CloseContactPolicy.observationLimit(treeConfidence:0.45,hp:67,nearbyThreats:0,health:0.5)==7)
  print("PASS: verified weak tree contact2; uncertain, large, hostile and low-health7")
 }
}
