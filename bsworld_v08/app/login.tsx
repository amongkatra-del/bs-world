import { useState } from "react";
import { router } from "expo-router";
import { View, Text, TextInput, Pressable, StyleSheet, Alert } from "react-native";
import { supabase } from "@/lib/supabase";
import { theme } from "@/lib/theme";

export default function Login() {
  const [email,setEmail]=useState("");
  const [password,setPassword]=useState("");
  const [busy,setBusy]=useState(false);

  async function signIn(){
    if(!supabase) return Alert.alert("Setup required","Add EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY first.");
    if(!email || !password) return Alert.alert("Missing details","Enter email and password.");
    setBusy(true);
    const {error}=await supabase.auth.signInWithPassword({email,password});
    setBusy(false);
    if(error) return Alert.alert("Login failed",error.message);
    router.replace("/home");
  }

  return <View style={s.root}>
    <Text style={s.brand}>bs<Text style={s.dot}>.</Text>world</Text>
    <Text style={s.title}>Welcome back 👋</Text>
    <Text style={s.sub}>Log in to continue</Text>
    <TextInput style={s.input} placeholder="Email" placeholderTextColor={theme.muted} value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address"/>
    <TextInput style={s.input} placeholder="Password" placeholderTextColor={theme.muted} value={password} onChangeText={setPassword} secureTextEntry/>
    <Pressable style={s.button} onPress={signIn} disabled={busy}><Text style={s.buttonText}>{busy?"Signing in…":"Log In"}</Text></Pressable>
    <Pressable onPress={()=>router.push("/signup")}><Text style={s.link}>Create a new account</Text></Pressable>
  </View>
}
const s=StyleSheet.create({
 root:{flex:1,backgroundColor:theme.bg,padding:24,justifyContent:"center"},
 brand:{fontSize:40,fontWeight:"800",color:"#fff",textAlign:"center"},dot:{color:theme.purple},
 title:{color:"#fff",fontSize:25,fontWeight:"800",marginTop:40},sub:{color:theme.muted,marginTop:7,marginBottom:25},
 input:{height:54,borderRadius:14,borderWidth:1,borderColor:theme.border,backgroundColor:theme.card,color:"#fff",paddingHorizontal:16,marginBottom:13},
 button:{height:54,borderRadius:15,backgroundColor:theme.purple,alignItems:"center",justifyContent:"center",marginTop:8},
 buttonText:{color:"#fff",fontSize:16,fontWeight:"800"},link:{color:"#B990FF",textAlign:"center",marginTop:22}
});
