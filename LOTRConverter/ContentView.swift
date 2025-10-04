//
//  ContentView.swift
//  LOTRConverter
//
//  Created by 阿福 on 30/09/2025.
//

import SwiftUI
import TipKit

struct ContentView: View {
    @State var showExchangeInfo = false
    @State var showSelectCurrency = false
    
    @State var leftAmount = ""
    @State var rightAmount = ""
    
    @FocusState var leftTyping
    @FocusState var rightTyping
    
//    @State var leftCurrency: Currency = .silverPiece
//    @State var rightCurrency: Currency = .goldPiece
    
    @AppStorage("leftCurrency") private var leftCurrencyRaw = Currency.silverPiece.rawValue
    @AppStorage("rightCurrency") private var rightCurrencyRaw = Currency.goldPiece.rawValue
    
    // 计算属性：把 rawValue 转换成 Currency
    var leftCurrency: Currency {
        get { Currency(rawValue: leftCurrencyRaw) ?? .silverPiece }
        set { leftCurrencyRaw = newValue.rawValue }
    }
    
    var rightCurrency: Currency {
        get { Currency(rawValue: rightCurrencyRaw) ?? .goldPiece }
        set { rightCurrencyRaw = newValue.rawValue }
    }
    
    
    let currencyTip = CurrencyTip()
    
    var body: some View {
        ZStack{
            // Background image
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                // Prancing pony image
                Image(.prancingpony)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Currency exchange text
                Text("Currency Exchange")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                // Conversion section
                HStack{
                    // Left conversion section
                    VStack{
                        // Currency
                        HStack{
                            // Currency image
                            Image(leftCurrency.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 33)
                            
                            // Currency text
                            Text(leftCurrency.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                        }
                        .padding(.bottom, -5)
                        .onTapGesture {
                            showSelectCurrency.toggle()
                            currencyTip.invalidate(reason: .actionPerformed)
                        }
                        .popoverTip(currencyTip, arrowEdge: .bottom)
                        
                        // Text field
                        TextField("Amount", text: $leftAmount)
                            .textFieldStyle(.roundedBorder)
                            .focused($leftTyping)
                    }
                    
                    // Equal sign
                    Image(systemName: "equal")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse)
                    
                    // Right conversion section
                    VStack{
                        // Currency∆
                        HStack{
                            // Currency text
                            Text(rightCurrency.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            // Currency image
                            Image(rightCurrency.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 33)
                        }
                        .padding(.bottom, -5)
                        .onTapGesture {
                            showSelectCurrency.toggle()
                            currencyTip.invalidate(reason: .actionPerformed)
                        }
                        
                        // Text field
                        TextField("Amount", text: $rightAmount)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                            .focused($rightTyping)
                    }
                }
                .padding()
                .background(.black.opacity(0.5))
                .clipShape(.capsule)
                .keyboardType(.decimalPad)
                
                Spacer()
                
                // Info button
                HStack {
                    Spacer()
                    
                    Button{
                        showExchangeInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing)
                }
            }
        }
        .task {
            try? Tips.configure()
        }
        .onChange(of: leftAmount) {
            if !leftTyping { return }
            rightAmount = leftCurrency.convert(leftAmount, to: rightCurrency)
        }
        .onChange(of: rightAmount) {
            if !rightTyping { return }
            leftAmount = rightCurrency.convert(rightAmount, to: leftCurrency)
        }
        .onChange(of: leftCurrency) {
            leftAmount = rightCurrency.convert(rightAmount, to: leftCurrency)
        }
        .onChange(of: rightCurrency) {
            rightAmount = leftCurrency.convert(leftAmount, to: rightCurrency)
        }
        .sheet(isPresented: $showExchangeInfo) {
            ExchangeInfo()
        }
        .sheet(isPresented: $showSelectCurrency) {
            SelectCurrency(topCurrency: Binding(
                get: { leftCurrency },
                set: { leftCurrency = $0 }
            ), bottomCurrency: Binding(
                get: { rightCurrency },
                set: { rightCurrency = $0 }
            ))
        }
    }
}

#Preview {
    ContentView()
}
