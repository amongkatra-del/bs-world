import { useEffect, useState } from "react";
import { View, Text, TextInput, Pressable, FlatList, StyleSheet, Alert } from "react-native";
import { router } from "expo-router";
import { supabase } from "@/lib/supabase";
import { theme } from "@/lib/theme";

export default function Contacts(){
  const [q,setQ]=useState("");
  const [users,setUsers]=useState<any[]>([]);
  const [loading,setLoading]=useState(true);

  async function load(){
    if(!supabase) return;
    setLoading(true);
    const {data,error}=await supabase.from("profiles")
      .select("id,username,display_name,avatar_url")
      .ilike("username", `%${q.toLowerCase()}%`)
      .limit(30);
    setLoading(false);
    if(error) Alert.alert("Contacts error",error.message);
    else setUsers(data||[]);
  }
  useEffect(()=>{load()},[]);

  return <View style={s.root}>
    <Text style={s.title}>Contacts</Text>
    <TextInput value={q} onChangeText={setQ} onSubmitEditing={load} style={s.input} placeholder="Search username…" placeholderTextColor={theme.muted} autoCapitalize="none"/>
    <Pressable style={s.search} onPress={load}><Text style={s.searchText}>Search</Text></Pressable>
    <FlatList
      data={users}
      keyExtractor={x=>x.id}
      refreshing={loading}
      onRefresh={load}
      renderItem={({item})=><Pressable style={s.row} onPress={()=>router.push({pathname:"/chat",params:{profileId:item.id,name:item.display_name}})}>
        <View style={s.avatar}><Text style={s.avatarText}>{(item.display_name||item.username)[0].toUpperCase()}</Text></View>
        <View><Text style={s.name}>{item.display_name}</Text><Text style={s.username}>@{item.username}</Text></View>
      </Pressable>}
    />
    <Pressable style={s.back} onPress={()=>router.replace("/home")}><Text style={s.backText}>← Back</Text></Pressable>
  </View>
}
const s=StyleSheet.create({
 root:{flex:1,backgroundColor:theme.bg,padding:20,paddingTop:55},title:{color:"#fff",fontSize:28,fontWeight:"800",marginBottom:18},
 input:{height:52,borderRadius:15,borderWidth:1,borderColor:theme.border,backgroundColor:theme.card,color:"#fff",paddingHorizontal:15},search:{height:48,borderRadius:14,backgroundColor:theme.purple,alignItems:"center",justifyContent:"center",marginVertical:12},searchText:{color:"#fff",fontWeight:"800"},
 row:{flexDirection:"row",alignItems:"center",gap:13,paddingVertical:14,borderBottomWidth:1,borderBottomColor:theme.border},avatar:{width:50,height:50,borderRadius:18,backgroundColor:theme.card2,alignItems:"center",justifyContent:"center",borderWidth:1,borderColor:theme.purple},avatarText:{color:"#fff",fontSize:19,fontWeight:"800"},name:{color:"#fff",fontSize:16,fontWeight:"700"},username:{color:theme.muted,marginTop:3},back:{paddingVertical:18},backText:{color:"#B990FF",fontWeight:"700"}
});
