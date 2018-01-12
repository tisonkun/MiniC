var t0
t0 = 0
var t1
t1 = 1
var t2
t2 = 40
f__2 [2]
var T0
var t3
t3 = 0
T0 = t3
l0:
var t4
t4 = 0
var t5
t5 = p0 != t4
var t6
t6 = t5 == t0
if t6 == t1 goto l1
var t7
t7 = 4
var t8
t8 = t7 * T0
var t9
t9 = p1 + t8
var t10
t10 = 2
var t11
t11 = p0 % t10
t9 [0] = t11
var t12
t12 = 1
var t13
t13 = T0 + t12
T0 = t13
var t14
t14 = 2
var t15
t15 = p0 / t14
p0 = t15
goto l0
l1:
var T1
T1 = T0
l2:
var t16
t16 = 40
var t17
t17 = T1 < t16
var t18
t18 = t17 == t0
if t18 == t1 goto l3
var t19
t19 = 4
var t20
t20 = t19 * T1
var t21
t21 = p1 + t20
var t22
t22 = 0
t21 [0] = t22
var t23
t23 = 1
var t24
t24 = T1 + t23
T1 = t24
goto l2
l3:
return T0
end f__2
f__xor [2]
var t25
t25 = 40
var 160 T2
var t26
t26 = 40
var 160 T3
param p0
param T2
var t27
t27 = call f__2
param p1
param T3
var t28
t28 = call f__2
var T4
var t29
t29 = 40
var t30
t30 = 1
var t31
t31 = t29 - t30
T4 = t31
var T5
var t32
t32 = 0
T5 = t32
l4:
var t33
t33 = 1
var t34
t34 = - t33
var t35
t35 = T4 != t34
var t36
t36 = t35 == t0
if t36 == t1 goto l5
var t37
t37 = 4
var t38
t38 = t37 * T4
var t39
t39 = T2 + t38
var t40
t40 = 4
var t41
t41 = t40 * T4
var t42
t42 = T3 + t41
var t43
t43 = t39 [0]
var t44
t44 = t42 [0]
var t45
t45 = t43 + t44
var t46
t46 = 1
var t47
t47 = t45 == t46
var t48
t48 = t47 == t0
if t48 == t1 goto l6
var t49
t49 = 2
var t50
t50 = T5 * t49
var t51
t51 = 1
var t52
t52 = t50 + t51
T5 = t52
goto l7
l6:
var t53
t53 = 2
var t54
t54 = T5 * t53
T5 = t54
l7:
var t55
t55 = 1
var t56
t56 = T4 - t55
T4 = t56
goto l4
l5:
return T5
end f__xor
f_putGame [1]
var t57
t57 = 71
param t57
var t58
t58 = call f_putchar
var t59
t59 = 97
param t59
var t60
t60 = call f_putchar
var t61
t61 = 109
param t61
var t62
t62 = call f_putchar
var t63
t63 = 101
param t63
var t64
t64 = call f_putchar
var t65
t65 = 32
param t65
var t66
t66 = call f_putchar
param p0
var t67
t67 = call f_putint
var t68
t68 = 58
param t68
var t69
t69 = call f_putchar
var t70
t70 = 32
param t70
var t71
t71 = call f_putchar
var t72
t72 = 0
return t72
end f_putGame
var t73
t73 = 25
var 100 T6
var T7
var t74
t74 = 25
var 100 T8
f_test [0]
var t75
t75 = 100
param t75
var t76
t76 = call f_putchar
param T7
var t77
t77 = call f_putint
var T9
var t78
t78 = 0
T9 = t78
var T10
var t79
t79 = 0
T10 = t79
l8:
var t80
t80 = T10 < T7
var t81
t81 = t80 == t0
if t81 == t1 goto l9
var t82
t82 = 4
var t83
t83 = t82 * T10
var t84
t84 = T8 + t83
var t85
t85 = 2
var t86
t86 = t84 [0]
var t87
t87 = t86 % t85
var t88
t88 = 1
var t89
t89 = t87 == t88
var t90
t90 = t89 == t0
if t90 == t1 goto l10
var t91
t91 = T7 - T10
var t92
t92 = 1
var t93
t93 = t91 - t92
var t94
t94 = 4
var t95
t95 = t94 * t93
var t96
t96 = T6 + t95
param T9
var t97
t97 = t96 [0]
param t97
var t98
t98 = call f__xor
T9 = t98
l10:
var t99
t99 = 1
var t100
t100 = T10 + t99
T10 = t100
goto l8
l9:
return T9
end f_test
f_main [0]
var t101
t101 = 0
var t102
t102 = 4
var t103
t103 = t102 * t101
var t104
t104 = T6 + t103
var t105
t105 = 0
t104 [0] = t105
var T11
var t106
t106 = 1
T11 = t106
l11:
var t107
t107 = 25
var t108
t108 = T11 < t107
var t109
t109 = t108 == t0
if t109 == t1 goto l12
var t110
t110 = 100
var 400 T12
var T13
var T14
var t111
t111 = 0
T13 = t111
l13:
var t112
t112 = 100
var t113
t113 = T13 < t112
var t114
t114 = t113 == t0
if t114 == t1 goto l14
var t115
t115 = 4
var t116
t116 = t115 * T13
var t117
t117 = T12 + t116
var t118
t118 = 0
t117 [0] = t118
var t119
t119 = 1
var t120
t120 = T13 + t119
T13 = t120
goto l13
l14:
var t121
t121 = 0
T13 = t121
l15:
var t122
t122 = T13 < T11
var t123
t123 = t122 == t0
if t123 == t1 goto l16
var t124
t124 = 0
T14 = t124
l17:
var t125
t125 = 1
var t126
t126 = T13 + t125
var t127
t127 = T14 < t126
var t128
t128 = t127 == t0
if t128 == t1 goto l18
var t129
t129 = 4
var t130
t130 = t129 * T13
var t131
t131 = T6 + t130
var t132
t132 = 4
var t133
t133 = t132 * T14
var t134
t134 = T6 + t133
var t135
t135 = t131 [0]
param t135
var t136
t136 = t134 [0]
param t136
var t137
t137 = call f__xor
var t138
t138 = 4
var t139
t139 = t138 * t137
var t140
t140 = T12 + t139
var t141
t141 = 1
t140 [0] = t141
var t142
t142 = 1
var t143
t143 = T14 + t142
T14 = t143
goto l17
l18:
var t144
t144 = 1
var t145
t145 = T13 + t144
T13 = t145
goto l15
l16:
var t146
t146 = 0
T13 = t146
var T15
var t147
t147 = 0
T15 = t147
l19:
var t148
t148 = 100
var t149
t149 = T13 < t148
var t150
t150 = t149 == t0
if t150 == t1 goto l20
var t151
t151 = ! T15
l20:
var t152
t152 = t149 != t0
var t153
t153 = t151 != t0
var t154
t154 = t152 && t153
var t155
t155 = t154 == t0
if t155 == t1 goto l21
var t156
t156 = 4
var t157
t157 = t156 * T13
var t158
t158 = T12 + t157
var t159
var t160
t160 = t158 [0]
t159 = ! t160
var t161
t161 = t159 == t0
if t161 == t1 goto l22
var t162
t162 = 4
var t163
t163 = t162 * T11
var t164
t164 = T6 + t163
t164 [0] = T13
var t165
t165 = 1
T15 = t165
l22:
var t166
t166 = 1
var t167
t167 = T13 + t166
T13 = t167
goto l19
l21:
var t168
t168 = 1
var t169
t169 = T11 + t168
T11 = t169
goto l11
l12:
var t170
t170 = call f_getint
T7 = t170
var T16
var t171
t171 = 1
T16 = t171
l23:
var t172
t172 = 0
var t173
t173 = T7 != t172
var t174
t174 = t173 == t0
if t174 == t1 goto l24
var T17
var t175
t175 = 0
T17 = t175
l25:
var t176
t176 = T17 < T7
var t177
t177 = t176 == t0
if t177 == t1 goto l26
var t178
t178 = 4
var t179
t179 = t178 * T17
var t180
t180 = T8 + t179
var t181
t181 = call f_getint
t180 [0] = t181
var t182
t182 = 1
var t183
t183 = T17 + t182
T17 = t183
goto l25
l26:
param T16
var t184
t184 = call f_putGame
param T7
var t185
t185 = call f_putint
var t186
t186 = 1
var t187
t187 = T16 + t186
T16 = t187
var t188
t188 = call f_test
var t189
t189 = t188 == t0
if t189 == t1 goto l27
var t190
t190 = 0
T17 = t190
var T18
var t191
t191 = 0
T18 = t191
l28:
var t192
t192 = T17 < T7
var t193
t193 = t192 == t0
if t193 == t1 goto l29
var t194
t194 = ! T18
l29:
var t195
t195 = t192 != t0
var t196
t196 = t194 != t0
var t197
t197 = t195 && t196
var t198
t198 = t197 == t0
if t198 == t1 goto l30
var t199
t199 = 4
var t200
t200 = t199 * T17
var t201
t201 = T8 + t200
var t202
t202 = t201 [0]
var t203
t203 = t202 == t0
if t203 == t1 goto l31
var T19
var T20
var t204
t204 = 1
var t205
t205 = T17 + t204
T19 = t205
l32:
var t206
t206 = T19 < T7
var t207
t207 = t206 == t0
if t207 == t1 goto l33
var t208
t208 = ! T18
l33:
var t209
t209 = t206 != t0
var t210
t210 = t208 != t0
var t211
t211 = t209 && t210
var t212
t212 = t211 == t0
if t212 == t1 goto l34
T20 = T19
l35:
var t213
t213 = T20 < T7
var t214
t214 = t213 == t0
if t214 == t1 goto l36
var t215
t215 = ! T18
l36:
var t216
t216 = t213 != t0
var t217
t217 = t215 != t0
var t218
t218 = t216 && t217
var t219
t219 = t218 == t0
if t219 == t1 goto l37
var t220
t220 = 4
var t221
t221 = t220 * T17
var t222
t222 = T8 + t221
var t223
t223 = 4
var t224
t224 = t223 * T17
var t225
t225 = T8 + t224
var t226
t226 = 1
var t227
t227 = t225 [0]
var t228
t228 = t227 - t226
t222 [0] = t228
var t229
t229 = 4
var t230
t230 = t229 * T19
var t231
t231 = T8 + t230
var t232
t232 = 4
var t233
t233 = t232 * T19
var t234
t234 = T8 + t233
var t235
t235 = 1
var t236
t236 = t234 [0]
var t237
t237 = t236 + t235
t231 [0] = t237
var t238
t238 = 4
var t239
t239 = t238 * T20
var t240
t240 = T8 + t239
var t241
t241 = 4
var t242
t242 = t241 * T20
var t243
t243 = T8 + t242
var t244
t244 = 1
var t245
t245 = t243 [0]
var t246
t246 = t245 + t244
t240 [0] = t246
var t247
t247 = call f_test
var t248
t248 = ! t247
var t249
t249 = t248 == t0
if t249 == t1 goto l38
param T17
var t250
t250 = call f_putint
var t251
t251 = 32
param t251
var t252
t252 = call f_putchar
param T19
var t253
t253 = call f_putint
var t254
t254 = 32
param t254
var t255
t255 = call f_putchar
param T20
var t256
t256 = call f_putint
var t257
t257 = 10
param t257
var t258
t258 = call f_putchar
var t259
t259 = 1
T18 = t259
l38:
var t260
t260 = 4
var t261
t261 = t260 * T17
var t262
t262 = T8 + t261
var t263
t263 = 4
var t264
t264 = t263 * T17
var t265
t265 = T8 + t264
var t266
t266 = 1
var t267
t267 = t265 [0]
var t268
t268 = t267 + t266
t262 [0] = t268
var t269
t269 = 4
var t270
t270 = t269 * T19
var t271
t271 = T8 + t270
var t272
t272 = 4
var t273
t273 = t272 * T19
var t274
t274 = T8 + t273
var t275
t275 = 1
var t276
t276 = t274 [0]
var t277
t277 = t276 - t275
t271 [0] = t277
var t278
t278 = 4
var t279
t279 = t278 * T20
var t280
t280 = T8 + t279
var t281
t281 = 4
var t282
t282 = t281 * T20
var t283
t283 = T8 + t282
var t284
t284 = 1
var t285
t285 = t283 [0]
var t286
t286 = t285 - t284
t280 [0] = t286
var t287
t287 = 1
var t288
t288 = T20 + t287
T20 = t288
goto l35
l37:
var t289
t289 = 1
var t290
t290 = T19 + t289
T19 = t290
goto l32
l34:
l31:
var t291
t291 = 1
var t292
t292 = T17 + t291
T17 = t292
goto l28
l30:
goto l39
l27:
var t293
t293 = 1
var t294
t294 = - t293
param t294
var t295
t295 = call f_putint
var t296
t296 = 32
param t296
var t297
t297 = call f_putchar
var t298
t298 = 1
var t299
t299 = - t298
param t299
var t300
t300 = call f_putint
var t301
t301 = 32
param t301
var t302
t302 = call f_putchar
var t303
t303 = 1
var t304
t304 = - t303
param t304
var t305
t305 = call f_putint
var t306
t306 = 10
param t306
var t307
t307 = call f_putchar
l39:
var t308
t308 = call f_getint
T7 = t308
goto l23
l24:
var t309
t309 = 0
return t309
end f_main
