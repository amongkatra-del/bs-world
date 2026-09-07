import { useState } from "react";
import { router } from "expo-router";
import { View, Text, TextInput, Pressable, StyleSheet, Alert } from "react-native";
import { supabase } from "@/lib/supabase";
import { theme } from "@/lib/theme";

export default function Signup(){
  const [name,setName]=useState(""); const [username,setUsername]=useState("");
  const [email,setEmail]=useState(""); const [password,setPassword]=useState(""); const [busy,setBusy]=useState(false);

  async function create(){
    if(!supabase) return Alert.alert("Setup required","Add the Supabase environment variables first.");
    if(!name||!username||!email||password.length<6) return Alert.alert("Check details","Enter all fields; password must be at least 6 characters.");
    setBusy(true);
    const {data,error}=await supabase.auth.signUp({email,password});
    if(error){setBusy(false);return Alert.alert("Sign up failed",error.message);}
    if(data.user){
      const {error:pErr}=await supabase.from("profiles").insert({id:data.user.id,display_name:name,username:username.toLowerCase()});
      if(pErr){setBusy(false);return Alert.alert("Profile failed",pErr.message);}
    }
    setBusy(false);
    Alert.alert("Account created","Check your email if confirmation is enabled.",[{text:"OK",onPress:()=>router.replace("/login")}]);
  }

  return <View style={s.root}>
    <Text style={s.brand}>bs<Text style={s.dot}>.</Text>world</Text>
    <Text style={s.title}>Create account</Text>
    <TextInput style={s.input} placeholder="Full name" placeholderTextColor={theme.muted} value={name} onChangeText={setName}/>
    <TextInput style={s.input} placeholder="Username" placeholderTextColor={theme.muted} value={username} onChangeText={setUsername} autoCapitalize="none"/>
    <TextInput style={s.input} placeholder="Email" placeholderTextColor={theme.muted} value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address"/>
    <TextInput style={s.input} placeholder="Password" placeholderTextColor={theme.muted} value={password} onChangeText={setPassword} secureTextEntry/>
    <Pressable style={s.button} onPress={create} disabled={busy}><Text style={s.buttonText}>{busy?"Creating…":"Sign Up"}</Text></Pressable>
    <Pressable onPress={()=>router.replace("/login")}><Text style={s.link}>Already have an account? Log in</Text></Pressable>
  </View>
}
const s=StyleSheet.create({
 root:{flex:1,backgroundColor:theme.bg,padding:24,justifyContent:"center"},
 brand:{fontSize:40,fontWeight:"800",color:"#fff",textAlign:"center",marginBottom:35},dot:{color:theme.purple},
 title:{color:"#fff",fontSize:26,fontWeight:"800",marginBottom:20},
 input:{height:54,borderRadius:14,borderWidth:1,borderColor:theme.border,backgroundColor:theme.card,color:"#fff",paddingHorizontal:16,marginBottom:13},
 button:{height:54,borderRadius:15,backgroundColor:theme.purple,alignItems:"center",justifyContent:"center",marginTop:8},
 buttonText:{color:"#fff",fontSize:16,fontWeight:"800"},link:{color:"#B990FF",textAlign:"center",marginTop:22}
});
