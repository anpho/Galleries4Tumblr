/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bb/cascades/LocaleHandler>
#include <bb/system/InvokeManager>
using namespace bb::cascades;
using namespace bb::system;

ApplicationUI::ApplicationUI() :
        QObject()
{
    // prepare the localization
    m_pTranslator = new QTranslator(this);
    m_pLocaleHandler = new LocaleHandler(this);

    bool res = QObject::connect(m_pLocaleHandler, SIGNAL(systemLanguageChanged()), this,
            SLOT(onSystemLanguageChanged()));
    // This is only available in Debug builds
    Q_ASSERT(res);
    // Since the variable is not used in the app, this is added to avoid a
    // compiler warning
    Q_UNUSED(res);

    // initial load
    onSystemLanguageChanged();

    // Create scene document from main.qml asset, the parent is set
    // to ensure the document gets destroyed properly at shut down.
    QmlDocument *qml = QmlDocument::create("qrc:/assets/main.qml").parent(this);
    qml->setContextProperty("_app", this);
    // Create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();

    // Set created root object as the application scene
    Application::instance()->setScene(root);
}

void ApplicationUI::onSystemLanguageChanged()
{
    QCoreApplication::instance()->removeTranslator(m_pTranslator);
    // Initiate, load and install the application translation files.
    QString locale_string = QLocale().name();
    QString file_name = QString("WPCollection_%1").arg(locale_string);
    if (m_pTranslator->load(file_name, "app/native/qm")) {
        QCoreApplication::instance()->installTranslator(m_pTranslator);
    }
}

void ApplicationUI::viewimage(QString path)
{
    InvokeManager invokeManageronImage;
    InvokeRequest request;

    // Set the URI
    request.setUri(path);
    request.setTarget("sys.pictures.card.previewer");
    request.setAction("bb.action.VIEW");
    // Send the invocation request
    InvokeTargetReply *cardreply = invokeManageronImage.invoke(request);
    Q_UNUSED(cardreply);
}

void ApplicationUI::shareImage(QString path)
{
    InvokeQuery *query = InvokeQuery::create().mimeType("image/jpeg").uri(path);
    Invocation *invocation = Invocation::create(query);
    query->setParent(invocation); // destroy query with invocation
    invocation->setParent(this); // app can be destroyed before onFinished() is called
    connect(invocation, SIGNAL(armed()), this, SLOT(onImageArmed()));
    connect(invocation, SIGNAL(finished()), this, SLOT(onFinished()));
}

void ApplicationUI::onImageArmed()
{
    Invocation *invocation = qobject_cast<Invocation *>(sender());
    invocation->trigger("bb.action.SHARE");
}
void ApplicationUI::onFinished()
{
    Invocation *invocation = qobject_cast<Invocation *>(sender());
    invocation->deleteLater();
}

QString ApplicationUI::getv(const QString &objectName, const QString &defaultValue)
{
    QSettings settings;
    if (settings.value(objectName).isNull()) {
        qDebug()<<"[SETTINGS]" << objectName << " is "<<defaultValue;
        return defaultValue;
    }
    qDebug()<<"[SETTINGS]" << objectName << " is "<<settings.value(objectName).toString();
    return settings.value(objectName).toString();
}

void ApplicationUI::setv(const QString &objectName, const QString &inputValue)
{
    QSettings settings;
    settings.setValue(objectName, QVariant(inputValue));
    qDebug() << "[SETTINGS]" << objectName << " set to " << inputValue;
}


QString ApplicationUI::readTextFile(QString filepath)
{
    QFile file(filepath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "";
    QString c = "";
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        c.append(line).append("\r\n");
    }
    return c;
}

bool ApplicationUI::writeTextFile(QString filepath, QString filecontent)
{
    qDebug()<<"export file path : " << filepath << " with content : " << filecontent ;
    QFile textfile(filepath);
    if (textfile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&textfile);
        out << filecontent;
        textfile.close();
        return (true);
    } else {
        return (false);
    }

}
