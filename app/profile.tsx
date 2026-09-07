import { useEffect, useState } from "react";
import { View, Text, Pressable, StyleSheet, Alert } from "react-native";
import { router } from "expo-router";
import { supabase } from "@/lib/supabase";
import { theme } from "@/lib/theme";

export default function Profile(){
  const [profile,setProfile]=useState<any>(null);
  useEffect(()=>{
    (async()=>{
      if(!supabase)return;
      const {data:{user}}=await supabase.auth.getUser();
      if(!user)return router.replace("/login");
      const {data}=await supabase.from("profiles").select("*").eq("id",user.id).single();
      setProfile(data);
    })();
  },[]);
  async function logout(){
    if(!supabase)return;
    const {error}=await supabase.auth.signOut();
    if(error) Alert.alert("Logout failed",error.message); else router.replace("/login");
  }
  return <View style={s.root}>
    <View style={s.avatar}><Text style={s.avatarText}>{(profile?.display_name||"?")[0]}</Text></View>
    <Text style={s.name}>{profile?.display_name||"Loading…"}</Text>
    <Text style={s.username}>{profile?.username?`@${profile.username}`:""}</Text>
    <View style={s.card}><Text style={s.label}>About</Text><Text style={s.value}>{profile?.bio||"No bio yet."}</Text></View>
    <Pressable style={s.item}><Text style={s.itemText}>Privacy & Security</Text><Text style={s.chev}>›</Text></Pressable>
    <Pressable style={s.item}><Text style={s.itemText}>Notifications</Text><Text style={s.chev}>›</Text></Pressable>
    <Pressable style={s.item}><Text style={s.itemText}>Data & Storage</Text><Text style={s.chev}>›</Text></Pressable>
    <Pressable style={s.logout} onPress={logout}><Text style={s.logoutText}>Sign out</Text></Pressable>
  </View>
}
const s=StyleSheet.create({
 root:{flex:1,backgroundColor:theme.bg,padding:24,paddingTop:65},avatar:{width:100,height:100,borderRadius:50,backgroundColor:theme.card2,borderWidth:2,borderColor:theme.purple,alignItems:"center",justifyContent:"center",alignSelf:"center"},avatarText:{color:"#fff",fontSize:40,fontWeight:"800"},name:{color:"#fff",fontSize:25,fontWeight:"800",textAlign:"center",marginTop:15},username:{color:theme.muted,textAlign:"center",marginTop:5},card:{backgroundColor:theme.card,borderRadius:16,padding:16,marginTop:30},label:{color:theme.muted,fontSize:12},value:{color:"#fff",marginTop:6},item:{height:56,borderBottomWidth:1,borderBottomColor:theme.border,flexDirection:"row",alignItems:"center",justifyContent:"space-between"},itemText:{color:"#fff",fontSize:15},chev:{color:theme.muted,fontSize:25},logout:{height:52,borderRadius:14,borderWidth:1,borderColor:theme.danger,alignItems:"center",justifyContent:"center",marginTop:25},logoutText:{color:"#FF7287",fontWeight:"800"}
});
