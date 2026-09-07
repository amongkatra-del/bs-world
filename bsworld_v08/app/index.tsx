import { useEffect } from "react";
import { router } from "expo-router";
import { View, Text, StyleSheet } from "react-native";
import { theme } from "@/lib/theme";

export default function Splash() {
  useEffect(() => {
    const t = setTimeout(() => router.replace("/login"), 1200);
    return () => clearTimeout(t);
  }, []);

  return (
    <View style={styles.root}>
      <View style={styles.logo}><Text style={styles.logoText}>b</Text></View>
      <Text style={styles.brand}>bs<Text style={styles.dot}>.</Text>world</Text>
      <Text style={styles.tag}>Connect. Share. Belong.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  root:{flex:1,backgroundColor:theme.bg,alignItems:"center",justifyContent:"center"},
  logo:{width:92,height:92,borderRadius:28,backgroundColor:theme.purple,alignItems:"center",justifyContent:"center",marginBottom:18},
  logoText:{fontSize:68,fontWeight:"900",color:"#fff"},
  brand:{fontSize:40,fontWeight:"800",color:"#fff"},
  dot:{color:theme.purple},
  tag:{marginTop:8,color:theme.muted,fontSize:15}
});