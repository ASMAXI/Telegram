// Copyright (c) the JPEG XL Project Authors. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#ifndef LIB_JXL_DCT_SCALES_H_
#define LIB_JXL_DCT_SCALES_H_

// Scaling factors.

#include <stddef.h>

namespace jxl {

static constexpr float kSqrt2 = 1.41421356237f;
static constexpr float kSqrt0_5 = 0.70710678118f;

// For n != 0, the n-th basis function of a N-DCT, evaluated in pixel k, has a
// value of cos((k+1/2) n/(2N) pi). When downsampling by 2x, we average
// the values for pixel k and k+1 to get the value for pixel (k/2), thus we get
//
// [cos((k+1/2) n/N pi) + cos((k+3/2) n/N pi)]/2 =
// cos(n/(2N) pi) cos((k+1) n/N pi) =
// cos(n/(2N) pi) cos(((k/2)+1/2) n/(N/2) pi)
//
// which is exactly the same as the value of pixel k/2 of a N/2-sized DCT,
// except for the cos(n/(2N) pi) scaling factor (which does *not*
// depend on the pixel). Thus, when using the lower-frequency coefficients of a
// DCT-N to compute a DCT-(N/2), they should be scaled by this constant. Scaling
// factors for a DCT-(N/4) etc can then be obtained by successive
// multiplications. The structs below contain the above-mentioned scaling
// factors.
//
// Python code for the tables below:
//
// for i in range(N // 8):
//    v = math.cos(i / (2 * N) * math.pi)
//    v *= math.cos(i / (N) * math.pi)
//    v *= math.cos(i / (N / 2) * math.pi)
//    print(v, end=", ")

template <size_t FROM, size_t TO>
struct DCTResampleScales;

template <>
struct DCTResampleScales<8, 1> {
  static constexpr float kScales[] = {
      1.000000000000000000,
  };
};

template <>
struct DCTResampleScales<16, 2> {
  static constexpr float kScales[] = {
      1.000000000000000000,
      0.901764195028874394,
  };
};

template <>
struct DCTResampleScales<32, 4> {
  static constexpr float kScales[] = {
      1.000000000000000000,
      0.974886821136879522,
      0.901764195028874394,
      0.787054918159101335,
  };
};

template <>
struct DCTResampleScales<64, 8> {
  static constexpr float kScales[] = {
      1.0000000000000000, 0.9936866130906366, 0.9748868211368796,
      0.9440180941651672, 0.9017641950288744, 0.8490574973847023,
      0.7870549181591013, 0.7171081282466044,
  };
};

template <>
struct DCTResampleScales<128, 16> {
  static constexpr float kScales[] = {
      1.0,
      0.9984194528776054,
      0.9936866130906366,
      0.9858278282666936,
      0.9748868211368796,
      0.9609244059440204,
      0.9440180941651672,
      0.9242615922757944,
      0.9017641950288744,
      0.8766500784429904,
      0.8490574973847023,
      0.8191378932865928,
      0.7870549181591013,
      0.7529833816270532,
      0.7171081282466044,
      0.6796228528314651,
  };
};

template <>
struct DCTResampleScales<256, 32> {
  static constexpr float kScales[] = {
      1.0,
      0.9996047255830407,
      0.9984194528776054,
      0.9964458326264695,
      0.9936866130906366,
      0.9901456355893141,
      0.9858278282666936,
      0.9807391980963174,
      0.9748868211368796,
      0.9682788310563117,
      0.9609244059440204,
      0.9528337534340876,
      0.9440180941651672,
      0.9344896436056892,
      0.9242615922757944,
      0.913348084400198,
      0.9017641950288744,
      0.8895259056651056,
      0.8766500784429904,
      0.8631544288990163,
      0.8490574973847023,
      0.8343786191696513,
      0.8191378932865928,
      0.8033561501721485,
      0.7870549181591013,
      0.7702563888779096,
      0.7529833816270532,
      0.7352593067735488,
      0.7171081282466044,
      0.6985543251889097,
      0.6796228528314651,
      0.6603391026591464,
  };
};

// Inverses of the above.
template <>
struct DCTResampleScales<1, 8> {
  static constexpr float kScales[] = {
      1.000000000000000000,
  };
};

template <>
struct DCTResampleScales<2, 16> {
  static constexpr float kScales[] = {
      1.000000000000000000,
      1.108937353592731823,
  };
};

template <>
struct DCTResampleScales<4, 32> {
  static constexpr float kScales[] = {
      1.000000000000000000,
      1.025760096781116015,
      1.108937353592731823,
      1.270559368765487251,
  };
};

template <>
struct DCTResampleScales<8, 64> {
  static constexpr float kScales[] = {
      1.0000000000000000, 1.0063534990068217, 1.0257600967811158,
      1.0593017296817173, 1.1089373535927318, 1.1777765381970435,
      1.2705593687654873, 1.3944898413647777,
  };
};

template <>
struct DCTResampleScales<16, 128> {
  static constexpr float kScales[] = {
      1.0,
      1.0015830492062623,
      1.0063534990068217,
      1.0143759095928793,
      1.0257600967811158,
      1.0406645869480142,
      1.0593017296817173,
      1.0819447744633812,
      1.1089373535927318,
      1.1407059950032632,
      1.1777765381970435,
      1.2207956782315876,
      1.2705593687654873,
      1.3280505578213306,
      1.3944898413647777,
      1.4714043176061107,
  };
};

template <>
struct DCTResampleScales<32, 256> {
  static constexpr float kScales[] = {
      1.0,
      1.0003954307206069,
      1.0015830492062623,
      1.0035668445360069,
      1.0063534990068217,
      1.009952439375063,
      1.0143759095928793,
      1.0196390660647288,
      1.0257600967811158,
      1.0327603660498115,
      1.0406645869480142,
      1.049501024072585,
      1.0593017296817173,
      1.0701028169146336,
      1.0819447744633812,
      1.0948728278734026,
      1.1089373535927318,
      1.124194353004584,
      1.1407059950032632,
      1.158541237256391,
      1.1777765381970435,
      1.1984966740820495,
      1.2207956782315876,
      1.244777922949508,
      1.2705593687654873,
      1.2982690107339132,
      1.3280505578213306,
      1.3600643892400104,
      1.3944898413647777,
      1.4315278911623237,
      1.4714043176061107,
      1.5143734423314616,
  };
};

// Constants for DCT implementation. Generated by the following snippet:
// for i in range(N // 2):
//    print(1.0 / (2 * math.cos((i + 0.5) * math.pi / N)), end=", ")
template <size_t N>
struct WcMultipliers;

template <>
struct WcMultipliers<4> {
  static constexpr float kMultipliers[] = {
      0.541196100146197,
      1.3065629648763764,
  };
};

template <>
struct WcMultipliers<8> {
  static constexpr float kMultipliers[] = {
      0.5097955791041592,
      0.6013448869350453,
      0.8999762231364156,
      2.5629154477415055,
  };
};

template <>
struct WcMultipliers<16> {
  static constexpr float kMultipliers[] = {
      0.5024192861881557, 0.5224986149396889, 0.5669440348163577,
      0.6468217833599901, 0.7881546234512502, 1.060677685990347,
      1.7224470982383342, 5.101148618689155,
  };
};

template <>
struct WcMultipliers<32> {
  static constexpr float kMultipliers[] = {
      0.5006029982351963, 0.5054709598975436, 0.5154473099226246,
      0.5310425910897841, 0.5531038960344445, 0.5829349682061339,
      0.6225041230356648, 0.6748083414550057, 0.7445362710022986,
      0.8393496454155268, 0.9725682378619608, 1.1694399334328847,
      1.4841646163141662, 2.057781009953411,  3.407608418468719,
      10.190008123548033,
  };
};
template <>
struct WcMultipliers<64> {
  static constexpr float kMultipliers[] = {
      0.500150636020651,  0.5013584524464084, 0.5037887256810443,
      0.5074711720725553, 0.5124514794082247, 0.5187927131053328,
      0.52657731515427,   0.535909816907992,  0.5469204379855088,
      0.5597698129470802, 0.57465518403266,   0.5918185358574165,
      0.6115573478825099, 0.6342389366884031, 0.6603198078137061,
      0.6903721282002123, 0.7251205223771985, 0.7654941649730891,
      0.8127020908144905, 0.8683447152233481, 0.9345835970364075,
      1.0144082649970547, 1.1120716205797176, 1.233832737976571,
      1.3892939586328277, 1.5939722833856311, 1.8746759800084078,
      2.282050068005162,  2.924628428158216,  4.084611078129248,
      6.796750711673633,  20.373878167231453,
  };
};
template <>
struct WcMultipliers<128> {
  static constexpr float kMultipliers[] = {
      0.5000376519155477, 0.5003390374428216, 0.5009427176380873,
      0.5018505174842379, 0.5030651913013697, 0.5045904432216454,
      0.5064309549285542, 0.5085924210498143, 0.5110815927066812,
      0.5139063298475396, 0.5170756631334912, 0.5205998663018917,
      0.524490540114724,  0.5287607092074876, 0.5334249333971333,
      0.538499435291984,  0.5440022463817783, 0.549953374183236,
      0.5563749934898856, 0.5632916653417023, 0.5707305880121454,
      0.5787218851348208, 0.5872989370937893, 0.5964987630244563,
      0.606362462272146,  0.6169357260050706, 0.6282694319707711,
      0.6404203382416639, 0.6534518953751283, 0.6674352009263413,
      0.6824501259764195, 0.6985866506472291, 0.7159464549705746,
      0.7346448236478627, 0.7548129391165311, 0.776600658233963,
      0.8001798956216941, 0.8257487738627852, 0.8535367510066064,
      0.8838110045596234, 0.9168844461846523, 0.9531258743921193,
      0.9929729612675466, 1.036949040910389,  1.0856850642580145,
      1.1399486751015042, 1.2006832557294167, 1.2690611716991191,
      1.346557628206286,  1.4350550884414341, 1.5369941008524954,
      1.6555965242641195, 1.7952052190778898, 1.961817848571166,
      2.163957818751979,  2.4141600002500763, 2.7316450287739396,
      3.147462191781909,  3.7152427383269746, 4.5362909369693565,
      5.827688377844654,  8.153848602466814,  13.58429025728446,
      40.744688103351834,
  };
};

template <>
struct WcMultipliers<256> {
  static constexpr float kMultipliers[128] = {
      0.5000094125358878, 0.500084723455784,  0.5002354020255269,
      0.5004615618093246, 0.5007633734146156, 0.5011410648064231,
      0.5015949217281668, 0.502125288230386,  0.5027325673091954,
      0.5034172216566842, 0.5041797745258774, 0.5050208107132756,
      0.5059409776624396, 0.5069409866925212, 0.5080216143561264,
      0.509183703931388,  0.5104281670536573, 0.5117559854927805,
      0.5131682130825206, 0.5146659778093218, 0.516250484068288,
      0.5179230150949777, 0.5196849355823947, 0.5215376944933958,
      0.5234828280796439, 0.52552196311921,   0.5276568203859896,
      0.5298892183652453, 0.5322210772308335, 0.5346544231010253,
      0.537191392591309,  0.5398342376841637, 0.5425853309375497,
      0.545447171055775,  0.5484223888484947, 0.551513753605893,
      0.554724179920619,  0.5580567349898085, 0.5615146464335654,
      0.5651013106696203, 0.5688203018875696, 0.5726753816701664,
      0.5766705093136241, 0.5808098529038624, 0.5850978012111273,
      0.58953897647151,   0.5941382481306648, 0.5989007476325463,
      0.6038318843443582, 0.6089373627182432, 0.614223200800649,
      0.6196957502119484, 0.6253617177319102, 0.6312281886412079,
      0.6373026519855411, 0.6435930279473415, 0.6501076975307724,
      0.6568555347890955, 0.6638459418498757, 0.6710888870233562,
      0.6785949463131795, 0.6863753486870501, 0.6944420255086364,
      0.7028076645818034, 0.7114857693151208, 0.7204907235796304,
      0.7298378629074134, 0.7395435527641373, 0.749625274727372,
      0.7601017215162176, 0.7709929019493761, 0.7823202570613161,
      0.7941067887834509, 0.8063772028037925, 0.8191580674598145,
      0.83247799080191,   0.8463678182968619, 0.860860854031955,
      0.8759931087426972, 0.8918035785352535, 0.9083345588266809,
      0.9256319988042384, 0.9437459026371479, 0.962730784794803,
      0.9826461881778968, 1.0035572754078206, 1.0255355056139732,
      1.048659411496106,  1.0730154944316674, 1.0986992590905857,
      1.1258164135986009, 1.1544842669978943, 1.184833362908442,
      1.217009397314603,  1.2511754798461228, 1.287514812536712,
      1.326233878832723,  1.3675662599582539, 1.411777227500661,
      1.459169302866857,  1.5100890297227016, 1.5649352798258847,
      1.6241695131835794, 1.6883285509131505, 1.7580406092704062,
      1.8340456094306077, 1.9172211551275689, 2.0086161135167564,
      2.1094945286246385, 2.22139377701127,   2.346202662531156,
      2.486267909203593,  2.644541877144861,  2.824791402350551,
      3.0318994541759925, 3.2723115884254845, 3.5547153325075804,
      3.891107790700307,  4.298537526449054,  4.802076008665048,
      5.440166215091329,  6.274908408039339,  7.413566756422303,
      9.058751453879703,  11.644627325175037, 16.300023088031555,
      27.163977662448232, 81.48784219222516,
  };
};

// Apply the DCT algorithm-intrinsic constants to DCTResampleScale.
template <size_t FROM, size_t TO>
constexpr float DCTTotalResampleScale(size_t x) {
  return DCTResampleScales<FROM, TO>::kScales[x];
}

}  // namespace jxl

#endif  // LIB_JXL_DCT_SCALES_H_